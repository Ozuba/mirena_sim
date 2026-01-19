extends RosMsg
class_name RosNavMsgsGoals

func _init():
	init("nav_msgs/msg/Goals")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var goals : Array:
	get: return get_member(&"goals")
	set(v): set_member(&"goals", v)

