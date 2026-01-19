extends RosMsg
class_name RosGeometryMsgsPoseWithCovariance

func _init():
	init("geometry_msgs/msg/PoseWithCovariance")

var pose : RosGeometryMsgsPose:
	get: return get_member(&"pose") as RosMsg
	set(v): set_member(&"pose", v)

var covariance : PackedFloat64Array:
	get: return get_member(&"covariance")
	set(v): set_member(&"covariance", v)

