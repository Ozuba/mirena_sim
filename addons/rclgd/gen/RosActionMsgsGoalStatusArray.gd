extends RosMsg
class_name RosActionMsgsGoalStatusArray

func _init():
	init("action_msgs/msg/GoalStatusArray")

var status_list : Array:
	get: return get_member(&"status_list")
	set(v): set_member(&"status_list", v)

