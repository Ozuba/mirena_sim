extends RosMsg
class_name RosGeometryMsgsPolygonInstanceStamped

func _init():
	init("geometry_msgs/msg/PolygonInstanceStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var polygon : RosGeometryMsgsPolygonInstance:
	get: return get_member(&"polygon") as RosMsg
	set(v): set_member(&"polygon", v)

