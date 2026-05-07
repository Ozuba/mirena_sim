extends RosMsg
class_name RosNavMsgsTrajectoryPoint

func _init():
	init("nav_msgs/msg/TrajectoryPoint")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var pose : RosGeometryMsgsPose:
	get: return get_member(&"pose") as RosMsg
	set(v): set_member(&"pose", v)

var velocity : RosGeometryMsgsTwist:
	get: return get_member(&"velocity") as RosMsg
	set(v): set_member(&"velocity", v)

var acceleration : RosGeometryMsgsAccel:
	get: return get_member(&"acceleration") as RosMsg
	set(v): set_member(&"acceleration", v)

var effort : RosGeometryMsgsWrench:
	get: return get_member(&"effort") as RosMsg
	set(v): set_member(&"effort", v)

