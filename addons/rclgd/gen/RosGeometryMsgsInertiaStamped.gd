extends RosMsg
class_name RosGeometryMsgsInertiaStamped

func _init():
	init("geometry_msgs/msg/InertiaStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var inertia : RosGeometryMsgsInertia:
	get: return get_member(&"inertia") as RosMsg
	set(v): set_member(&"inertia", v)

