extends RosMsg
class_name RosStdMsgsUInt8MultiArray

func _init():
	init("std_msgs/msg/UInt8MultiArray")

var layout : RosStdMsgsMultiArrayLayout:
	get: return get_member(&"layout") as RosMsg
	set(v): set_member(&"layout", v)

var data : PackedByteArray:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

