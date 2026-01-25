extends RosMsg
class_name RosMirenaCommonEntityList

func _init():
	init("mirena_common/msg/EntityList")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var entities : Array:
	get: return get_member(&"entities")
	set(v): set_member(&"entities", v)
