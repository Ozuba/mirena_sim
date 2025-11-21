extends RefCounted
class_name CarStateBroadcaster 
# Must not outlive its owner

#Physics
var _previous_linear_velocity: Vector3 = Vector3.ZERO
var _previous_angular_velocity: Vector3 = Vector3.ZERO

var _linear_acceleration: Vector3 = Vector3.ZERO
var _angular_acceleration: Vector3 = Vector3.ZERO

# Broadcast
var _car_broadcast_accumulator: float = 0
var _car_broadcast_period: float = 0.1 # seconds
var _control_broadcast_accumulator: float = 0
var _control_broadcast_period: float = 0.1 # seconds
var _perception_cones_broadcast_accumulator: float = 0
var _perception_cones_broadcast_period: float = 0.1 # seconds
var _track_broadcast_period: float = 0.1 # seconds
var _track_broadcast_accumulator: float = 0 



var _owner: WeakRef
var owner: MirenaCar: 
	get():
		return _owner.get_ref()
	set(value):
		_owner = weakref(value)

func _init(owner_: MirenaCar) -> void:
	self.owner = owner_

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
	self._car_broadcast_accumulator += delta
	if self._car_broadcast_accumulator >= self._car_broadcast_period:
		self._car_broadcast_accumulator = fmod(self._car_broadcast_accumulator, self._car_broadcast_period)
		ROS.publish_car_state(owner.position, owner.rotation, owner.linear_velocity, owner.angular_velocity, _linear_acceleration, _angular_acceleration)
		
	########### CONTROL BROADCASTING #############
	self._control_broadcast_accumulator += delta
	if self._control_broadcast_accumulator >= self._control_broadcast_period:
		self._control_broadcast_accumulator = fmod(self._control_broadcast_accumulator, self._control_broadcast_period)
		ROS.publish_inferred_control(owner.gas, owner.steering)
	
	########### PERCEPTION CONES BROADCASTING #############
	self._perception_cones_broadcast_accumulator += delta
	if self._perception_cones_broadcast_accumulator >= self._perception_cones_broadcast_period:
		self._perception_cones_broadcast_accumulator = fmod(self._perception_cones_broadcast_accumulator, self._perception_cones_broadcast_period)
		ROS.publish_perception_entities(owner.get_perception_area().get_cones_in_sigth().map(func (cone: Node3D): return owner.to_local(cone.position)))
		
	########### TRACK BROADCASTING #############
	self._track_broadcast_accumulator += delta
	if self._track_broadcast_accumulator >= self._track_broadcast_period:
		self._track_broadcast_accumulator = fmod(self._track_broadcast_accumulator, self._track_broadcast_period)
		ROS.publish_track(SIM.get_track_manager().get_gates_array(),SIM.get_track_manager().is_closed())
