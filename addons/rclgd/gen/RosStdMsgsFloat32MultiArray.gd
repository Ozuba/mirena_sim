extends RosMsg
class_name RosStdMsgsFloat32MultiArray

func _init():
	init("std_msgs/msg/Float32MultiArray")

var layout : RosStdMsgsMultiArrayLayout:
	get: return get_member(&"layout") as RosMsg
	set(v): set_member(&"layout", v)

var data : PackedFloat32Array:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

