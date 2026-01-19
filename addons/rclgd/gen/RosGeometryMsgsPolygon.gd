extends RosMsg
class_name RosGeometryMsgsPolygon

func _init():
	init("geometry_msgs/msg/Polygon")

var points : Array:
	get: return get_member(&"points")
	set(v): set_member(&"points", v)

