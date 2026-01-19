extends RosMsg
class_name RosGeometryMsgsAccelWithCovarianceStamped

func _init():
	init("geometry_msgs/msg/AccelWithCovarianceStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var accel : RosGeometryMsgsAccelWithCovariance:
	get: return get_member(&"accel") as RosMsg
	set(v): set_member(&"accel", v)

