extends RosMsg
class_name RosStdMsgsFloat64MultiArray

func _init():
	init("std_msgs/msg/Float64MultiArray")

var layout : RosStdMsgsMultiArrayLayout:
	get: return get_member(&"layout") as RosMsg
	set(v): set_member(&"layout", v)

var data : PackedFloat64Array:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

