extends RosMsg
class_name RosStdMsgsInt32

func _init():
	init("std_msgs/msg/Int32")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

