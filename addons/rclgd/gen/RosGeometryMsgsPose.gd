extends RosMsg
class_name RosGeometryMsgsPose

func _init():
	init("geometry_msgs/msg/Pose")

var position : RosGeometryMsgsPoint:
	get: return get_member(&"position") as RosMsg
	set(v): set_member(&"position", v)

var orientation : RosGeometryMsgsQuaternion:
	get: return get_member(&"orientation") as RosMsg
	set(v): set_member(&"orientation", v)

