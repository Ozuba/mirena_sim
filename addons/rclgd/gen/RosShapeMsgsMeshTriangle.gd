extends RosMsg
class_name RosShapeMsgsMeshTriangle

func _init():
	init("shape_msgs/msg/MeshTriangle")

var vertex_indices : Array:
	get: return get_member(&"vertex_indices")
	set(v): set_member(&"vertex_indices", v)

