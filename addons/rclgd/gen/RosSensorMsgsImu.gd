extends RosMsg
class_name RosSensorMsgsImu

func _init():
	init("sensor_msgs/msg/Imu")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var orientation : RosGeometryMsgsQuaternion:
	get: return get_member(&"orientation") as RosMsg
	set(v): set_member(&"orientation", v)

var orientation_covariance : PackedFloat64Array:
	get: return get_member(&"orientation_covariance")
	set(v): set_member(&"orientation_covariance", v)

var angular_velocity : RosGeometryMsgsVector3:
	get: return get_member(&"angular_velocity") as RosMsg
	set(v): set_member(&"angular_velocity", v)

var angular_velocity_covariance : PackedFloat64Array:
	get: return get_member(&"angular_velocity_covariance")
	set(v): set_member(&"angular_velocity_covariance", v)

var linear_acceleration : RosGeometryMsgsVector3:
	get: return get_member(&"linear_acceleration") as RosMsg
	set(v): set_member(&"linear_acceleration", v)

var linear_acceleration_covariance : PackedFloat64Array:
	get: return get_member(&"linear_acceleration_covariance")
	set(v): set_member(&"linear_acceleration_covariance", v)

