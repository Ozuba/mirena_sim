extends RosMsg
class_name RosMirenaCommonWheelSpeeds

func _init():
	init("mirena_common/msg/WheelSpeeds")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var fl : float:
	get: return get_member(&"fl")
	set(v): set_member(&"fl", v)

var fr : float:
	get: return get_member(&"fr")
	set(v): set_member(&"fr", v)

var rl : float:
	get: return get_member(&"rl")
	set(v): set_member(&"rl", v)

var rr : float:
	get: return get_member(&"rr")
	set(v): set_member(&"rr", v)

