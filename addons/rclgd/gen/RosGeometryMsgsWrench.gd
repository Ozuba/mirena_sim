extends RosMsg
class_name RosGeometryMsgsWrench

func _init():
	init("geometry_msgs/msg/Wrench")

var force : RosGeometryMsgsVector3:
	get: return get_member(&"force") as RosMsg
	set(v): set_member(&"force", v)

var torque : RosGeometryMsgsVector3:
	get: return get_member(&"torque") as RosMsg
	set(v): set_member(&"torque", v)

