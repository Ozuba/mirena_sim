extends RosMsg
class_name RosStdMsgsByte

func _init():
	init("std_msgs/msg/Byte")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

