extends RosMsg
class_name RosStdMsgsUInt64MultiArray

func _init():
	init("std_msgs/msg/UInt64MultiArray")

var layout : RosStdMsgsMultiArrayLayout:
	get: return get_member(&"layout") as RosMsg
	set(v): set_member(&"layout", v)

var data : Array:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

