extends RosMsg
class_name RosVisualizationMsgsMeshFile

func _init():
	init("visualization_msgs/msg/MeshFile")

var filename : String:
	get: return get_member(&"filename")
	set(v): set_member(&"filename", v)

var data : PackedByteArray:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

