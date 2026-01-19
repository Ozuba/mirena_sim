extends RosMsg
class_name RosStdMsgsInt64

func _init():
	init("std_msgs/msg/Int64")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

