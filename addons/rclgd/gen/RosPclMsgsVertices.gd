extends RosMsg
class_name RosPclMsgsVertices

func _init():
	init("pcl_msgs/msg/Vertices")

var vertices : Array:
	get: return get_member(&"vertices")
	set(v): set_member(&"vertices", v)

