extends RosMsg
class_name RosGeometryMsgsPoseStamped

func _init():
	init("geometry_msgs/msg/PoseStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var pose : RosGeometryMsgsPose:
	get: return get_member(&"pose") as RosMsg
	set(v): set_member(&"pose", v)

