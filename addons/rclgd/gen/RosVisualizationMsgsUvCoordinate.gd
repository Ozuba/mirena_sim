extends RosMsg
class_name RosVisualizationMsgsUvCoordinate

func _init():
	init("visualization_msgs/msg/UVCoordinate")

var u : float:
	get: return get_member(&"u")
	set(v): set_member(&"u", v)

var v : float:
	get: return get_member(&"v")
	set(v): set_member(&"v", v)

