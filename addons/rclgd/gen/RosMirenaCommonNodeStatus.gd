extends RosMsg
class_name RosMirenaCommonNodeStatus

func _init():
	init("mirena_common/msg/NodeStatus")

var state : int:
	get: return get_member(&"state")
	set(v): set_member(&"state", v)

var state_info : String:
	get: return get_member(&"state_info")
	set(v): set_member(&"state_info", v)

