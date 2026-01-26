extends RosMsg
class_name RosMirenaCommonDebugEntityList

func _init():
	init("mirena_common/msg/DebugEntityList")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var entities : Array:
	get: return get_member(&"entities")
	set(v): set_member(&"entities", v)

