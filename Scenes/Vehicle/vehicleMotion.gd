extends VehicleBody3D
class_name MirenaCar

enum PilotMode { NO_PILOT, MANUAL, ROS, TRACK_RAIL, CONTROLLER }

# --- Configuration ---
const POWER_LIM = 80000 # W
const MOTOR_PEAK_TRQ = 100 # Nm
const GEAR_RATIO = 5 # 1:5
const WHEEL_RADIUS = 0.23 # m
const BRAKE_F = 20
const MAX_STEER = deg_to_rad(30)

# --- Pilot Settings ---
@export var pilot: PilotMode = PilotMode.NO_PILOT
@export var rail_speed: float = 10.0
@export var rail_look_ahead: float = 3.0
var _rail_progress: float = 0.0
var path : Path3D

# --- UI / Camera Background Additions ---
@export var target_display: TextureRect # <-- Assign your UI background node here in the inspector
var background_texture: ImageTexture = ImageTexture.new()

# --- ROS Variables ---
@export var frame_id: String = "~cog"
var _node: RosNode
# Publishers
var _state_pub: RosPublisher
var _can_dv_config_pub : RosPublisher
var _perception_pub: RosPublisher
var _slam_pub: RosPublisher
var _inferred_control_pub: RosPublisher
var _state_tim : RosTimer
var _debug_tim : RosTimer
# Subscribers
var _control_sub: RosSubscriber
var _camera_sub: RosSubscriber # <-- FIXED: Added missing variable declaration

var _tf_broadcaster: RosTfBroadcaster
var _ros_gas: float = 0.0
var _ros_steer: float = 0.0

# --- Internal State ---
var origin  : Transform3D = Transform3D.IDENTITY
var gas: float = 0.0
var _steer_smoothed: float = 0.0
var slam_cones: Array = [] # Seen cones

@onready var car_state : RosMirenaCommonCar = RosMirenaCommonCar.new()

func _init():
	child_entered_tree.connect(_on_child_entered_tree)

func _on_child_entered_tree(node: Node) -> void:
	if "ros_namespace" in node:
		node.ros_namespace = self.name.to_snake_case()
	
func _ready():
	## ROS
	_node = RosNode.new()
	_node.init(name.to_snake_case(),name.to_snake_case())
	## Publisher
	_can_dv_config_pub = _node.create_publisher("debug_dv_config", "mirena_common/msg/CanDvConfig")
	_state_pub = _node.create_publisher("debug_state","mirena_common/msg/Car")
	_perception_pub = _node.create_publisher("debug_perception","mirena_common/msg/EntityList")
	_slam_pub = _node.create_publisher("debug_slam","mirena_common/msg/EntityList")
	_inferred_control_pub = _node.create_publisher("inferred_control","mirena_common/msg/CarControl")
	## Publisher timers
	_debug_tim = _node.create_timer(0.1,_debug_publish)
	_state_tim = _node.create_timer(0.005,_publish_car_state)
	# Subscribers
	_control_sub = _node.create_subscriber("control", "mirena_common/msg/CarControl", _on_control)
	_camera_sub = _node.create_subscriber("mirena_camera/image", "sensor_msgs/msg/Image", _on_image)

	# Transforms
	_tf_broadcaster = _node.create_tf_broadcaster()
	
	# Camera Registration
	Sim.register_camera($TPCam)
	Sim.register_camera($FPCam)

func _on_image(msg):
	# FIXED: Ensure we only process if a target display UI is actually hooked up
	if pilot == PilotMode.CONTROLLER and target_display != null:
		var img := Image.new()
		var width := 640
		var height := 480
		var raw_bytes: PackedByteArray = msg.data
		
		img.create_from_data(width, height, false, Image.FORMAT_RGB8, raw_bytes)
		
		# FIXED: Use call_deferred to safely push texture modifications back to Godot's main thread
		_update_ui_texture.call_deferred(img)

# FIXED: Separate helper function to update UI on the main thread safely
func _update_ui_texture(img: Image) -> void:
	if background_texture.get_size() != Vector2(img.get_size()):
		background_texture = ImageTexture.create_from_image(img)
		target_display.texture = background_texture 
	else:
		background_texture.update(img)

func _on_control(msg):
	_ros_gas = msg.gas
	_ros_steer = msg.steer_angle

func _physics_process(delta: float) -> void:
	# Process driving commands
	match pilot:
		PilotMode.NO_PILOT:
			_process_no_pilot()
			_apply_vehicle_physics(delta)
		PilotMode.MANUAL:
			_process_manual_pilot(delta)
			_apply_vehicle_physics(delta)
		PilotMode.ROS:
			_process_ros_pilot()
			_apply_vehicle_physics(delta)
		PilotMode.TRACK_RAIL:
			_process_track_rail(delta)
		PilotMode.CONTROLLER:
			_process_controller_pilot(delta) # <-- FIXED: Passing delta down
			_apply_vehicle_physics(delta)
	
	if global_position.y < -1:
		reset_position()
		
# Publish Debug Info
func _debug_publish():
	_publish_perception()
	_publish_slam()
	_publish_control()
	
# ROS Publishing

## Car state (Substitutes sensor EKF)
func _publish_car_state():
	var now = _node.now()
	car_state.header.stamp = now
	car_state.header.frame_id = "debug_odom"
	car_state.child_frame_id = _node.resolve_frame(frame_id) 
	
	var odom_transform : Transform3D = origin.inverse() * global_transform
	# 1. Pose and Dynamics
	car_state.x = -odom_transform.origin.z
	car_state.y = -odom_transform.origin.x
	car_state.psi = odom_transform.basis.get_euler().y
	
	var local_vel = basis.inverse() * linear_velocity
	car_state.u = -local_vel.z
	car_state.v = -local_vel.x
	car_state.omega = angular_velocity.y
	
	var cov = []
	cov.resize(36)
	for i in range(36):
		cov[i] = 0.0 
		
	cov[0]  = 0 
	cov[7]  = 0  
	cov[14] = 0 
	cov[21] = 0  
	cov[28] = 0  
	cov[35] = 0  
	
	car_state.covariance = cov
	_tf_broadcaster.send_transform(odom_transform.translated(center_of_mass).inverse(),"debug_odom",frame_id, false,now)
	_tf_broadcaster.send_transform(origin.inverse(),"debug_map","debug_odom", false,now)

	_state_pub.publish(car_state)

func _publish_perception():
	var cones = get_cones_in_sight(12.0)
	for cone in cones:
		if not slam_cones.has(cone): slam_cones.append(cone)
	
	var msg = RosMirenaCommonEntityList.new()
	msg.header.stamp = _node.now()
	msg.header.frame_id = _node.resolve_frame(frame_id)
	msg.entities = cones.map(func(c): return _to_ent(c))
	_perception_pub.publish(msg)

func _publish_slam():
	var msg = RosMirenaCommonEntityList.new()
	msg.header.stamp = _node.now()
	msg.header.frame_id = "map"
	slam_cones = slam_cones.filter(func(c): return is_instance_valid(c))
	msg.entities = slam_cones.map(func(c): return _to_ent(c,true))
	_slam_pub.publish(msg)

func _publish_control():
	var msg = RosMirenaCommonCarControl.new()
	msg.header.stamp = _node.now()
	msg.header.frame_id = "map"
	msg.gas = self.gas
	msg.steer_angle = self.steering

	_inferred_control_pub.publish(msg)

# Conversion helper
func _to_ent(cone: Node3D, global : bool = false  ) -> RosMirenaCommonEntity:
	var ent = RosMirenaCommonEntity.new()
	var pos =  cone.global_position if global else to_local(cone.global_position)
	ent.type = cone.get_type_as_string()
	
	# ROS Swizzle: Forward=Z, Left=-X, Up=Y
	ent.position.x = -pos.z
	ent.position.y = -pos.x
	ent.position.z = pos.y
	return ent

# --- Pilot Logic ---

func _process_no_pilot() -> void:
	self.gas = 0.0
	self.steering = 0.0
	self.brake = BRAKE_F 

func _process_manual_pilot(delta: float) -> void:
	var steer_input = Input.get_action_strength("manual_steer_l") - Input.get_action_strength("manual_steer_r")    
	_steer_smoothed = _smooth_steer(_steer_smoothed, steer_input, delta, 2.0) # FIXED: Added smoothing call matching controller mode
	self.gas = Input.get_action_strength("manual_gas_pos") - Input.get_action_strength("manual_gas_neg")
	self.steering = _steer_smoothed * MAX_STEER
	self.brake = Input.get_action_strength("EBS") * BRAKE_F

func _process_ros_pilot() -> void:
	self.gas = _ros_gas
	self.steering = _ros_steer 
	self.brake = 0.0 

func _process_track_rail(delta: float) -> void:
	if not path or not path.curve: 
		return

	_rail_progress += rail_speed * delta
	var local_transform = path.curve.sample_baked_with_rotation(_rail_progress, true)
	var target_global_transform = path.global_transform * local_transform
	
	var motion = target_global_transform.origin - global_position
	var collision = move_and_collide(motion)
	if collision:
		var remainder = collision.get_remainder().slide(collision.get_normal())
		move_and_collide(remainder)

	var look_ahead_p = _rail_progress + rail_look_ahead
	var look_target_local = path.curve.sample_baked_with_rotation(look_ahead_p, true)
	var look_target_global = path.global_transform * look_target_local
	
	global_transform.basis = global_transform.basis.slerp(
		look_target_global.basis.orthonormalized(), 
		5.0 * delta
	).orthonormalized()

func _process_controller_pilot(delta: float) -> void:
	# 1. Check if a controller is actually connected
	if Input.get_connected_joypads().is_empty():
		self.gas = 0.0
		self.steering = 0.0
		self.brake = BRAKE_F
		return

	var device_id = 0 

	# 2. Get Analog Steering (Left Stick X-Axis)
	# JOY_AXIS_LEFT_X returns -1.0 (Full Left) to 1.0 (Full Right)
	var steer_input = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	
	# Apply a small deadzone to prevent drift when the stick is resting
	if abs(steer_input) < 0.05:
		steer_input = 0.0
		
	_steer_smoothed = _smooth_steer(_steer_smoothed, steer_input, delta, 3.5) # Increased speed slightly for responsive analog feel
	self.steering = _steer_smoothed * MAX_STEER

	# 3. Get Analog Gas & Brake (Triggers)
	# Triggers rest at 0.0 and go up to 1.0 when fully pressed
	var trigger_gas = Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_RIGHT)
	var trigger_brake = Input.get_joy_axis(device_id, JOY_AXIS_TRIGGER_LEFT)

	self.gas = trigger_gas
	self.brake = trigger_brake * BRAKE_F
	
# --- Physics & Low Level Control ---

func _apply_vehicle_physics(_delta: float) -> void:
	var u = (global_transform.basis.inverse() * linear_velocity).z
	var max_fx_motor = MOTOR_PEAK_TRQ * GEAR_RATIO / WHEEL_RADIUS
	var max_fx_regen = 0.5 * (1.0 + tanh(u / 0.01)) * max_fx_motor
	
	var fx = min(gas, 0) * max_fx_regen + max(gas, 0) * max_fx_motor
	
	$RL_WHEEL.engine_force = fx / 2.0
	$RR_WHEEL.engine_force = fx / 2.0
	
	$RL_WHEEL.brake = brake
	$RR_WHEEL.brake = brake

func _smooth_steer(current: float, target: float, delta: float, speed: float) -> float:
	var diff = target - current
	var t = clamp(abs(diff), 0.0, 1.0)
	var _ease = t * t * (3.0 - 2.0 * t) 
	current += sign(diff) * _ease * speed * delta
	if sign(target - current) != sign(diff): current = target
	return clamp(current, -1.0, 1.0)

# --- Interface & Utility ---

func set_origin(transform, reset_vel: bool = false) -> void:
	origin = transform
	if reset_vel:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	await get_tree().process_frame
	set_deferred("global_transform", origin)

func reset_position() -> void:
	set_origin(Sim.track.origin, true)
	self.gas = 0
	self.steering = 0
	self.brake = 0
	_rail_progress = 0
	slam_cones.clear()

func cone_collision_set(enable: bool) -> void:
	self.collision_layer = (self.collision_layer & ~2) | (2 * int(enable))
	self.collision_mask = (self.collision_mask & ~2) | (2 * int(enable))
	
func get_cones_in_sight(max_dist: float = 10.0) -> Array:
	var visible_cones: Array = []
	var camera = $Camera._camera
	if not camera: return []
	for cone in get_tree().get_nodes_in_group("Cones"):
		if global_position.distance_to(cone.global_position) < max_dist:
			if camera.is_position_in_frustum(cone.global_position):
				visible_cones.append(cone)
	return visible_cones

func get_can_dv_config_pub():
	return self._can_dv_config_pub
