extends VehicleBody3D
class_name MirenaCar

enum PilotMode { NO_PILOT, MANUAL, ROS, TRACK_RAIL }

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

# --- ROS Variables ---
@export var frame_id: String = "~cog"
var _node: RosNode
# Publishers
var _state_pub: RosPublisher
var _perception_pub: RosPublisher
var _slam_pub: RosPublisher
var _state_tim : RosTimer
var _debug_tim : RosTimer
# Subscribers
var _control_sub: RosSubscriber

var _tf_broadcaster: RosTfBroadcaster
var _ros_gas: float = 0.0
var _ros_steer: float = 0.0

# --- Internal State ---
var gas: float = 0.0
var _steer_smoothed: float = 0.0
var slam_cones: Array = [] # Seen cones

func _ready():
	# 1. Initialize Sensors
	$Camera.init(name.to_snake_case())
	$Lidar.init(name.to_snake_case())
	$IMU/IMU.init(name.to_snake_case())
	
	## ROS
	_node = RosNode.new()
	_node.init(name.to_snake_case(),name.to_snake_case())
	## Publisher
	_state_pub = _node.create_publisher("state","mirena_common/msg/Car")
	_perception_pub = _node.create_publisher("debug_perception","mirena_common/msg/EntityList")
	_slam_pub = _node.create_publisher("debug_slam","mirena_common/msg/EntityList")
	## Publisher timers
	_debug_tim = _node.create_timer(0.1,_debug_publish)
	_state_tim = _node.create_timer(0.02,_publish_car_state)
	# Subscribers
	_control_sub = _node.create_subscriber("control", "mirena_common/msg/CarControl", _on_control)
	# Transforms
	_tf_broadcaster = _node.create_tf_broadcaster()

	
	# Camera Registration
	Sim.register_camera($TPCam)
	Sim.register_camera($FPCam)

func _on_control(msg):
	_ros_gas = msg.gas
	_ros_steer = msg.steer_angle

func _physics_process(delta: float) -> void:
	#Publish transform
	_tf_broadcaster.send_transform(global_transform, frame_id, "map", false)
	
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
	
	if global_position.y < -1:
		reset_position()
		
# Publish Debug Info
func _debug_publish():
	_publish_perception()
	_publish_slam()
	
# ROS Publishing
func _publish_car_state():
	var msg = RosMirenaCommonCar.new()
	msg.header.stamp = _node.now()
	msg.header.frame_id = "map"
	msg.x = global_position.z
	msg.y = global_position.x
	msg.psi = global_rotation.y
	
	var local_vel = basis.inverse() * linear_velocity
	msg.u = local_vel.z; msg.v = local_vel.x; msg.omega = angular_velocity.y
	_state_pub.publish(msg)

func _publish_perception():
	var cones = get_cones_in_sight(8.0)
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
	# Use Identity transform for global positions
	msg.entities = slam_cones.map(func(c): return _to_ent(c,true))
	_slam_pub.publish(msg)

# Conversion helper
func _to_ent(cone: Node3D, global : bool = false  ) -> RosMirenaCommonEntity:
	var ent = RosMirenaCommonEntity.new()
	var pos =  cone.global_position if global else to_local(cone.global_position)
	ent.type = cone.get_type_as_string()
	
	# ROS Swizzle: Forward=Z, Left=-X, Up=Y
	ent.position.x = pos.z
	ent.position.y = pos.x
	ent.position.z = pos.y
	return ent


# --- Pilot Logic ---

func _process_no_pilot() -> void:
	# Zero out all inputs to ensure the car stays stationary or coasts to a stop
	self.gas = 0.0
	self.steering = 0.0
	self.brake = BRAKE_F # Keep brakes engaged in No Pilot mode

func _process_manual_pilot(delta: float) -> void:
	var steer_input = Input.get_action_strength("manual_steer_l") - Input.get_action_strength("manual_steer_r")
	_steer_smoothed = _smooth_steer(_steer_smoothed, steer_input, delta, 2.0)
	
	self.gas = Input.get_action_strength("manual_gas_pos") - Input.get_action_strength("manual_gas_neg")
	self.steering = _steer_smoothed * MAX_STEER
	self.brake = Input.get_action_strength("EBS") * BRAKE_F

func _process_ros_pilot() -> void:
	self.gas = _ros_gas
	self.steering = _ros_steer 
	self.brake = 0.0 # Brakes handled by ROS if needed

func _process_track_rail(delta: float) -> void:
	if not path or not path.curve: 
		return

	# 1. Advance progress (meters)
	_rail_progress += rail_speed * delta
	
	# 2. Sample the curve math directly (No PathFollow node needed!)
	# This gives us the local Transform3D (position + orientation)
	var local_transform = path.curve.sample_baked_with_rotation(_rail_progress, true)
	
	# 3. Convert to Global Space
	# We multiply by the path's transform so the car follows the path where it sits in the world
	var target_global_transform = path.global_transform * local_transform
	
	# 4. Movement (Your move_and_collide approach)
	var motion = target_global_transform.origin - global_position
	var collision = move_and_collide(motion)
	if collision:
		var remainder = collision.get_remainder().slide(collision.get_normal())
		move_and_collide(remainder)

	# 5. Look-Ahead Orientation
	var look_ahead_p = _rail_progress + rail_look_ahead
	var look_target_local = path.curve.sample_baked_with_rotation(look_ahead_p, true)
	var look_target_global = path.global_transform * look_target_local
	
	# Adjust basis (Flip PI to face forward)
	var target_basis = look_target_global.basis * Basis(Vector3.UP, PI)
	
	# Smoothly rotate the car to face the look-ahead point
	global_transform.basis = global_transform.basis.slerp(
		target_basis.orthonormalized(), 
		5.0 * delta
	).orthonormalized()
# --- Physics & Low Level Control ---

func _apply_vehicle_physics(_delta: float) -> void:
	var u = (global_transform.basis.inverse() * linear_velocity).z
	var max_fx_motor = MOTOR_PEAK_TRQ * GEAR_RATIO / WHEEL_RADIUS
	var max_fx_regen = 0.5 * (1.0 + tanh(u / 0.01)) * max_fx_motor
	
	var fx = min(gas, 0) * max_fx_regen + max(gas, 0) * max_fx_motor
	
	$RL_WHEEL.engine_force = fx / 2.0
	$RR_WHEEL.engine_force = fx / 2.0
	
	# Apply braking force to wheels
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

func set_pose(pose, reset_vel: bool = false) -> void:
	var pos = Vector3(pose["y"], 0.1, pose["x"])
	if reset_vel:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	await get_tree().process_frame
	set_deferred("global_transform", Transform3D(Basis(Vector3.UP, pose["psi"]), pos))

func reset_position() -> void:
	set_pose(Sim.track.origin, true)
	self.gas = 0;
	self.steering = 0;
	self.brake = 0;
	_rail_progress = 0
	# Reset slam
	slam_cones.clear()

func cone_collision_set(enable: bool) -> void:
	self.collision_layer = (self.collision_layer & ~2) | (2 * int(enable))
	self.collision_mask = (self.collision_mask & ~2) | (2 * int(enable))
	
func get_cones_in_sight(max_dist: float = 10.0) -> Array:
	var visible_cones: Array = []
	var camera = $Camera/CameraViewport/Camera3D
	for cone in get_tree().get_nodes_in_group("Cones"):
		if global_position.distance_to(cone.global_position) < max_dist:
			if camera.is_position_in_frustum(cone.global_position):
				visible_cones.append(cone)
	return visible_cones
