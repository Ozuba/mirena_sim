extends RosMsg
class_name RosShapeMsgsMesh

func _init():
	init("shape_msgs/msg/Mesh")

var triangles : Array:
	get: return get_member(&"triangles")
	set(v): set_member(&"triangles", v)

var vertices : Array:
	get: return get_member(&"vertices")
	set(v): set_member(&"vertices", v)

