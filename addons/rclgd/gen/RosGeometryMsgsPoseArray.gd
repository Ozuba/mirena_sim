extends RosMsg
class_name RosGeometryMsgsPoseArray

func _init():
	init("geometry_msgs/msg/PoseArray")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var poses : Array:
	get: return get_member(&"poses")
	set(v): set_member(&"poses", v)

