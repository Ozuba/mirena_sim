extends RefCounted
class_name CarStateBroadcaster 

# Ros Related
var _node: RosNode
var _car_pub: RosPublisher
var _control_pub: RosPublisher
var _cones_pub: RosPublisher
var _track_pub : RosPublisher

#Physics
var _previous_linear_velocity: Vector3 = Vector3.ZERO
var _previous_angular_velocity: Vector3 = Vector3.ZERO

var _linear_acceleration: Vector3 = Vector3.ZERO
var _angular_acceleration: Vector3 = Vector3.ZERO



var _owner: WeakRef
var owner: MirenaCar: 
	get():
		return _owner.get_ref()
	set(value):
		_owner = weakref(value)

func _init(owner_: MirenaCar) -> void:
	# Set owner
	self.owner = owner_
	# Setup Node and publishers
	_node = RosNode.new()
	_node.init("DebugNode") 
	_car_pub = _node.create_publisher("/sim/debug/car","mirena_common/msg/Car")
	_control_pub = _node.create_publisher("/sim/debug/CarControl","mirena_common/msg/CarControl")
	_cones_pub = _node.create_publisher("/sim/debug/perception_cones","mirena_common/msg/EntityList")
	_track_pub = _node.create_publisher("/sim/debug/CarControl","mirena_common/msg/Track")
		

func get_owner() -> MirenaCar:
	return self._owner.get_ref()

func update(delta: float):
	########### ACCEL CALCULATION #############
	# Calculate linear acceleration
	_linear_acceleration = (get_owner().linear_velocity - _previous_linear_velocity) / delta
	_previous_linear_velocity = get_owner().linear_velocity

	# Calculate angular acceleration
	_angular_acceleration = (get_owner().angular_velocity - _previous_angular_velocity) / delta
	_previous_angular_velocity = get_owner().angular_velocity
	
	########### STATE BROADCASTING #############
	# If enough time has passed, broadcast the message
	
	#ROS.publish_car_state(owner.position, owner.rotation, owner.global_transform.basis.inverse() * owner.linear_velocity, owner.angular_velocity, _linear_acceleration, _angular_acceleration)
		
	########### CONTROL BROADCASTING #############
	#ROS.publish_inferred_control(owner.gas, owner.steering)
	
	########### PERCEPTION CONES BROADCASTING #############
	#ROS.publish_perception_entities(owner.get_perception_area().get_cones_in_sigth().map(func (cone: Node3D): return owner.to_local(cone.position)))
		
	########### TRACK BROADCASTING #############
		#ROS.publish_track(SIM.get_track_manager().get_gates_array(),SIM.get_track_manager().is_closed())


func publish_car():
	var msg = RosMirenaCommonCar.new()
	msg.x = owner.
	
