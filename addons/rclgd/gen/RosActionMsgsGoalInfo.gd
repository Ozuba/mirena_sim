extends RosMsg
class_name RosActionMsgsGoalInfo

func _init():
	init("action_msgs/msg/GoalInfo")

var goal_id : RosUniqueIdentifierMsgsUuid:
	get: return get_member(&"goal_id") as RosMsg
	set(v): set_member(&"goal_id", v)

var stamp : RosBuiltinInterfacesTime:
	get: return get_member(&"stamp") as RosMsg
	set(v): set_member(&"stamp", v)

