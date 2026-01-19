extends RosMsg
class_name RosVisualizationMsgsMarkerArray

func _init():
	init("visualization_msgs/msg/MarkerArray")

var markers : Array:
	get: return get_member(&"markers")
	set(v): set_member(&"markers", v)

