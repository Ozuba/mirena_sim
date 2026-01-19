extends RosMsg
class_name RosGeometryMsgsTwistWithCovariance

func _init():
	init("geometry_msgs/msg/TwistWithCovariance")

var twist : RosGeometryMsgsTwist:
	get: return get_member(&"twist") as RosMsg
	set(v): set_member(&"twist", v)

var covariance : PackedFloat64Array:
	get: return get_member(&"covariance")
	set(v): set_member(&"covariance", v)

