extends RosMsg
class_name RosGeometryMsgsPolygonStamped

func _init():
	init("geometry_msgs/msg/PolygonStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var polygon : RosGeometryMsgsPolygon:
	get: return get_member(&"polygon") as RosMsg
	set(v): set_member(&"polygon", v)

