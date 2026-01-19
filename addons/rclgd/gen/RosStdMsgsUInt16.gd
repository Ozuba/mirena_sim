extends RosMsg
class_name RosStdMsgsUInt16

func _init():
	init("std_msgs/msg/UInt16")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

