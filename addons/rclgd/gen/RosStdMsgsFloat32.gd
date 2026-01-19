extends RosMsg
class_name RosStdMsgsFloat32

func _init():
	init("std_msgs/msg/Float32")

var data : float:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

