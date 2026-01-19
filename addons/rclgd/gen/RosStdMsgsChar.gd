extends RosMsg
class_name RosStdMsgsChar

func _init():
	init("std_msgs/msg/Char")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

