extends RosMsg
class_name RosGeometryMsgsPolygonInstance

func _init():
	init("geometry_msgs/msg/PolygonInstance")

var polygon : RosGeometryMsgsPolygon:
	get: return get_member(&"polygon") as RosMsg
	set(v): set_member(&"polygon", v)

var id : int:
	get: return get_member(&"id")
	set(v): set_member(&"id", v)

