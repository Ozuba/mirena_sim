extends RosMsg
class_name RosGeometryMsgsPointStamped

func _init():
	init("geometry_msgs/msg/PointStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var point : RosGeometryMsgsPoint:
	get: return get_member(&"point") as RosMsg
	set(v): set_member(&"point", v)

