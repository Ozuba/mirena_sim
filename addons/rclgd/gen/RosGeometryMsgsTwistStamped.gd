extends RosMsg
class_name RosGeometryMsgsTwistStamped

func _init():
	init("geometry_msgs/msg/TwistStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var twist : RosGeometryMsgsTwist:
	get: return get_member(&"twist") as RosMsg
	set(v): set_member(&"twist", v)

