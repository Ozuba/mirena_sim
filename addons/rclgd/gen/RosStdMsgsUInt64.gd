extends RosMsg
class_name RosStdMsgsUInt64

func _init():
	init("std_msgs/msg/UInt64")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

