extends RosMsg
class_name RosGeometryMsgsAccelWithCovariance

func _init():
	init("geometry_msgs/msg/AccelWithCovariance")

var accel : RosGeometryMsgsAccel:
	get: return get_member(&"accel") as RosMsg
	set(v): set_member(&"accel", v)

var covariance : PackedFloat64Array:
	get: return get_member(&"covariance")
	set(v): set_member(&"covariance", v)

