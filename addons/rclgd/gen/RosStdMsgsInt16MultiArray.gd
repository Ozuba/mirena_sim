extends RosMsg
class_name RosStdMsgsInt16MultiArray

func _init():
	init("std_msgs/msg/Int16MultiArray")

var layout : RosStdMsgsMultiArrayLayout:
	get: return get_member(&"layout") as RosMsg
	set(v): set_member(&"layout", v)

var data : Array:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

