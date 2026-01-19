extends RosMsg
class_name RosActionlibMsgsGoalId

func _init():
	init("actionlib_msgs/msg/GoalID")

var stamp : RosBuiltinInterfacesTime:
	get: return get_member(&"stamp") as RosMsg
	set(v): set_member(&"stamp", v)

var id : String:
	get: return get_member(&"id")
	set(v): set_member(&"id", v)

