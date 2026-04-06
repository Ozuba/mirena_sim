extends RosMsg
class_name RosMirenaCommonAsStatus

func _init():
	init("mirena_common/msg/ASStatus")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var state : int:
	get: return get_member(&"state")
	set(v): set_member(&"state", v)

var mission : int:
	get: return get_member(&"mission")
	set(v): set_member(&"mission", v)
