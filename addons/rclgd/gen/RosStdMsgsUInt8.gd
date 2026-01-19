extends RosMsg
class_name RosStdMsgsUInt8

func _init():
	init("std_msgs/msg/UInt8")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

