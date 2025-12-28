extends Node3D

# Constants
var CAR_FRAME = "MirenaCar"
@export var publish_rate: float = 20.0
@export var target_car: MirenaCar
var _publish_timer: Timer

# Ros Related
var _node: RosNode
var _car_pub: RosPublisher
var _control_pub: RosPublisher
var _cones_pub: RosPublisher
var _track_pub : RosPublisher

# Physics
var _previous_linear_velocity: Vector3 = Vector3.ZERO
var _previous_angular_velocity: Vector3 = Vector3.ZERO
var _linear_acceleration: Vector3 = Vector3.ZERO
var _angular_acceleration: Vector3 = Vector3.ZERO

func _init() -> void:
	
	# Setup Node and publishers
	_node = RosNode.new()
	_node.init("DebugNode") 
	_car_pub = _node.create_publisher("/sim/debug/car","mirena_common/msg/Car")
	_control_pub = _node.create_publisher("/sim/debug/car_control_infered","mirena_common/msg/CarControl")
	_cones_pub = _node.create_publisher("/sim/debug/perception_cones","mirena_common/msg/EntityList")
	_track_pub = _node.create_publisher("/sim/debug/track","mirena_common/msg/Track")
	
	# Setup the timer
	_publish_timer = Timer.new()
	add_child(_publish_timer)
	_publish_timer.wait_time = 1.0 / publish_rate
	_publish_timer.one_shot = false
	_publish_timer.autostart = true
	
	# CONNECT SIGNAL: This makes it periodic
	_publish_timer.timeout.connect(_on_timer_timeout)


func _process(delta: float) -> void:
	# Keep the physics integration in update/physics_process to ensure 
	# acceleration is calculated accurately every frame.
	if delta <= 0: return
	
	_linear_acceleration = (target_car.linear_velocity - _previous_linear_velocity) / delta
	_previous_linear_velocity = target_car.linear_velocity

	_angular_acceleration = (target_car.angular_velocity - _previous_angular_velocity) / delta
	_previous_angular_velocity = target_car.angular_velocity


func _on_timer_timeout():
	# This function now runs at exactly 20Hz (or your set publish_rate)
	if not target_car: return
	########### PERCEPTION CONES BROADCASTING #############
	var cones_in_sight = $PerceptionArea.get_cones_in_sigth().map(
		func (cone: Node3D): return target_car.to_local(cone.position)
	)
	_publish_perception_entities(cones_in_sight)
		
	########### STATE BROADCASTING #############
	_publish_car_state(target_car.global_position, target_car.global_rotation, target_car.basis.inverse() * target_car.linear_velocity, target_car.angular_velocity, _linear_acceleration, _angular_acceleration)
		
	########### CONTROL BROADCASTING #############
	_publish_inferred_control(target_car.gas, target_car.steering)

	########### TRACK BROADCASTING #############
	var track_manager = SIM.get_track_manager()
	_publish_track(track_manager.get_gates_array(), track_manager.is_closed())


func _publish_car_state(position: Vector3, rotation: Vector3, lin_speed: Vector3, ang_speed: Vector3, lin_accel: Vector3, ang_accel: Vector3) -> void:
	var msg = RosMirenaCommonCar.new()
	msg.header.frame_id = "world"
	msg.header.stamp = _node.now()
	
	# --- POSITION (Strictly following your C++ header) ---
	msg.x = position.z
	msg.y = position.x

	msg.psi = rotation.y 
	
	# --- VELOCITIES (u = longitudinal, v = lateral) ---
	# Based on ROS X being Forward (Godot Z) and ROS Y being Left (Godot X)
	msg.u = lin_speed.z
	msg.v = lin_speed.x
	
	# --- OMEGA (Yaw Rate) ---
	# Rotation rate around the vertical (Godot Y) axis
	msg.omega = ang_speed.y
	
	_car_pub.publish(msg)


func _publish_perception_entities(entities: Array) -> void:
	# 1. Initialize the message list
	var msg = RosMirenaCommonEntityList.new()
	# 2. Iterate through provided entities
	msg.entities = entities.map(func(pos: Vector3):
		var entity = RosMirenaCommonEntity.new()
		entity.position.x = pos.z # ROS Swizzle
		entity.position.y = pos.x
		entity.position.z = pos.y
		return entity
		)
	# 5. Set header information
	msg.header.frame_id = CAR_FRAME
	msg.header.stamp = _node.now()
	# 6. Publish
	_cones_pub.publish(msg)
	
func _publish_inferred_control(gas: float, steer: float) -> void:
	# 1. Instantiate the custom message type
	var msg = RosMirenaCommonCarControl.new()
	
	# 2. Assign control values
	msg.gas = gas
	msg.steer_angle = steer
	
	# 3. Set header metadata
	# Assuming FIXED_FRAME_NAME is defined as a constant or variable in your script
	msg.header.frame_id = CAR_FRAME
	msg.header.stamp = _node.now()
	
	# 4. Publish to the debug topic
	_control_pub.publish(msg)


func _publish_track(gates: Array, is_closed: bool) -> void:
	var msg = RosMirenaCommonTrack.new()
	
	# 1. Create a standard GDScript array to hold the data
	var temp_gates: Array = []
	
	for gate_pos in gates:
		var gate = RosMirenaCommonGate.new()
		gate.x = gate_pos.x
		gate.y = gate_pos.y
		gate.psi = gate_pos.z
		
		# 2. Append to the local GDScript list (Fast)
		temp_gates.append(gate)
	
	# 3. Assign the entire list to the ROS message (Triggers C++ _set once)
	msg.gates = temp_gates
	
	msg.is_closed = is_closed
	msg.header.stamp = _node.now()
	_track_pub.publish(msg)
