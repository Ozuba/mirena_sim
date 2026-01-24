extends Node3D

# Constants
var CAR_FRAME = "MirenaCar"
@export var publish_rate: float = 1000.0
@export var target_car: MirenaCar
var _publish_timer: Timer

# Ros Related
var _node: RosNode
var _car_pub: RosPublisher
var _control_pub: RosPublisher
var _perception_pub: RosPublisher
var _track_pub : RosPublisher
var _map_pub : RosPublisher
var _slam_pub : RosPublisher

# Physics
var _previous_linear_velocity: Vector3 = Vector3.ZERO
var _previous_angular_velocity: Vector3 = Vector3.ZERO
var _linear_acceleration: Vector3 = Vector3.ZERO
var _angular_acceleration: Vector3 = Vector3.ZERO



# Slam cones
var slam_cones: Array = []

func _init() -> void:
	
	# Setup Node and publishers	
	_node = RosNode.new()
	_node.init("DebugNode") 
	_car_pub = _node.create_publisher("/sim/debug/car","mirena_common/msg/Car")
	_control_pub = _node.create_publisher("/sim/debug/car_control_infered","mirena_common/msg/CarControl")
	_perception_pub = _node.create_publisher("/sim/debug/perception_entities","mirena_common/msg/EntityList")
	_track_pub = _node.create_publisher("/sim/debug/track","mirena_common/msg/Track")
	_map_pub = _node.create_publisher("/sim/debug/full_map","mirena_common/msg/EntityList")
	_slam_pub = _node.create_publisher("/sim/debug/slam","mirena_common/msg/EntityList")

	
	# Setup the timer
	_publish_timer = Timer.new()
	add_child(_publish_timer)
	_publish_timer.wait_time = 1.0 / publish_rate
	_publish_timer.one_shot = false
	_publish_timer.autostart = true
	
	# CONNECT SIGNAL: This makes it periodic
	_publish_timer.timeout.connect(_on_timer_timeout)
	connect("track_loaded", _reset_slam)


func _process(delta: float) -> void:
	# Keep the physics integration in update/physics_process to ensure 
	# acceleration is calculated accurately every frame.
	if delta <= 0: return
	
	_linear_acceleration = (target_car.linear_velocity - _previous_linear_velocity) / delta
	_previous_linear_velocity = target_car.linear_velocity

	_angular_acceleration = (target_car.angular_velocity - _previous_angular_velocity) / delta
	_previous_angular_velocity = target_car.angular_velocity


func _on_timer_timeout():
	if not target_car: return
	########### PERCEPTION CONES BROADCASTING #############
	var cones_in_sight = $PerceptionArea.get_cones_in_sigth()
	_publish_perception_entities(cones_in_sight)
	
	########### PERCEPTION CONES BROADCASTING #############
	for cone in cones_in_sight:
		# Only add if no cone in the list is within 0.5m of this one
		if not slam_cones.has(cone):
			slam_cones.append(cone)
			
	_publish_slam(slam_cones)

	################# Full Map ###################
	
	_publish_map(get_tree().get_nodes_in_group("Cones"))
	
	########### STATE BROADCASTING #############
	_publish_car_state(target_car.global_position, target_car.global_rotation, target_car.basis.inverse() * target_car.linear_velocity, target_car.angular_velocity, _linear_acceleration, _angular_acceleration)
		
	########### CONTROL BROADCASTING #############
	_publish_inferred_control(target_car.gas, target_car.steering)

	########### TRACK BROADCASTING #############
	#var track_manager = SIM.get_track_manager()
	_publish_track(Sim.track.get_gate_positions(), Sim.track.track_curve.closed)


func _publish_car_state(position: Vector3, rotation: Vector3, lin_speed: Vector3, ang_speed: Vector3, lin_accel: Vector3, ang_accel: Vector3) -> void:
	var msg = RosMirenaCommonCar.new()
	msg.header.frame_id = "map"
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
	
func _reset_slam():
	slam_cones.clear()
			
func _publish_slam(entities: Array) -> void:
	# 1. Initialize the message list
	var msg = RosMirenaCommonEntityList.new()
	# 2. Iterate through provided entities
	msg.entities = entities.map(func(cone):
		var entity = RosMirenaCommonEntity.new()
		var pos = cone.global_position
		entity.position.x = pos.z 
		entity.position.y = pos.x
		entity.position.z = pos.y
		entity.type = cone.get_type_as_string()
		return entity
		)
	# 5. Set header information
	msg.header.frame_id = "map"
	msg.header.stamp = _node.now()
	# 6. Publish
	_slam_pub.publish(msg)
	


func _publish_map(entities: Array) -> void:
	# 1. Initialize the message list
	var msg = RosMirenaCommonEntityList.new()
	# 2. Iterate through provided entities
	msg.entities = entities.map(func(cone):
		var entity = RosMirenaCommonEntity.new()
		var pos = cone.global_position
		entity.position.x = pos.z 
		entity.position.y = pos.x
		entity.position.z = pos.y
		entity.type = cone.get_type_as_string()
		return entity
		)
	# 5. Set header information
	msg.header.frame_id = "map"
	msg.header.stamp = _node.now()
	# 6. Publish
	_map_pub.publish(msg)

func _publish_perception_entities(entities: Array) -> void:
	# 1. Initialize the message list
	var msg = RosMirenaCommonEntityList.new()
	# 2. Iterate through provided entities
	msg.entities = entities.map(func(cone):
		var entity = RosMirenaCommonEntity.new()
		var pos = to_local(cone.global_position)
		entity.position.x = pos.z 
		entity.position.y = pos.x
		entity.position.z = pos.y
		entity.type = cone.get_type_as_string()
		return entity
		)
	# 5. Set header information
	msg.header.frame_id = CAR_FRAME
	msg.header.stamp = _node.now()
	# 6. Publish
	_perception_pub.publish(msg)
	
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
		gate.psi = gate_pos.psi
		
		# 2. Append to the local GDScript list (Fast)
		temp_gates.append(gate)
	
	# 3. Assign the entire list to the ROS message (Triggers C++ _set once)
	msg.gates = temp_gates
	
	msg.is_closed = is_closed
	msg.header.stamp = _node.now()
	_track_pub.publish(msg)
