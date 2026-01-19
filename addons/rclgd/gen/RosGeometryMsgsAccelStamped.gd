extends RosMsg
class_name RosGeometryMsgsAccelStamped

func _init():
	init("geometry_msgs/msg/AccelStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var accel : RosGeometryMsgsAccel:
	get: return get_member(&"accel") as RosMsg
	set(v): set_member(&"accel", v)

