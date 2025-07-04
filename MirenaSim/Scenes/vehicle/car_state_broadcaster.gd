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

var _owner: WeakRef

var broadcas_enable: bool = true

func _init(owner: MirenaCar) -> void:
	self._owner = weakref(owner)

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
		self.get_owner().get_ros_car_base().ros_broadcast_car_state(get_owner().position, get_owner().rotation, get_owner().linear_velocity, get_owner().angular_velocity, _linear_acceleration, _angular_acceleration)

func set_broadcast_enable(value: bool) -> void:
	self.broadcas_enable = value
