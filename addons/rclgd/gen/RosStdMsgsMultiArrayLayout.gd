extends RosMsg
class_name RosStdMsgsMultiArrayLayout

func _init():
	init("std_msgs/msg/MultiArrayLayout")

var dim : Array:
	get: return get_member(&"dim")
	set(v): set_member(&"dim", v)

var data_offset : int:
	get: return get_member(&"data_offset")
	set(v): set_member(&"data_offset", v)

