extends RosMsg
class_name RosPclMsgsPointIndices

func _init():
	init("pcl_msgs/msg/PointIndices")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var indices : Array:
	get: return get_member(&"indices")
	set(v): set_member(&"indices", v)

