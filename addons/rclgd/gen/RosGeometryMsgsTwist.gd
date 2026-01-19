extends RosMsg
class_name RosGeometryMsgsTwist

func _init():
	init("geometry_msgs/msg/Twist")

var linear : RosGeometryMsgsVector3:
	get: return get_member(&"linear") as RosMsg
	set(v): set_member(&"linear", v)

var angular : RosGeometryMsgsVector3:
	get: return get_member(&"angular") as RosMsg
	set(v): set_member(&"angular", v)

