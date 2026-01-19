extends RosMsg
class_name RosGeometryMsgsVector3Stamped

func _init():
	init("geometry_msgs/msg/Vector3Stamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var vector : RosGeometryMsgsVector3:
	get: return get_member(&"vector") as RosMsg
	set(v): set_member(&"vector", v)

