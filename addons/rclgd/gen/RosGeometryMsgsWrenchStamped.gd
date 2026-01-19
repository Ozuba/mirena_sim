extends RosMsg
class_name RosGeometryMsgsWrenchStamped

func _init():
	init("geometry_msgs/msg/WrenchStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var wrench : RosGeometryMsgsWrench:
	get: return get_member(&"wrench") as RosMsg
	set(v): set_member(&"wrench", v)

