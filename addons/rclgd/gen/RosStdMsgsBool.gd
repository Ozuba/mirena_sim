extends RosMsg
class_name RosStdMsgsBool

func _init():
	init("std_msgs/msg/Bool")

var data : bool:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

