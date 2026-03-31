extends RosMsg
class_name RosMirenaCommonEmpty

func _init():
	init("mirena_common/msg/Empty")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

