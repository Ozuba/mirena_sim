extends RosMsg
class_name RosMirenaCommonTrack

func _init():
	init("mirena_common/msg/Track")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var gates : Array:
	get: return get_member(&"gates")
	set(v): set_member(&"gates", v)

var is_closed : int:
	get: return get_member(&"is_closed")
	set(v): set_member(&"is_closed", v)

