extends RosMsg
class_name RosPclMsgsModelCoefficients

func _init():
	init("pcl_msgs/msg/ModelCoefficients")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var values : PackedFloat32Array:
	get: return get_member(&"values")
	set(v): set_member(&"values", v)

