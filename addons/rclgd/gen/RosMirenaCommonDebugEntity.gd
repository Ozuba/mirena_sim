extends RosMsg
class_name RosMirenaCommonDebugEntity

func _init():
	init("mirena_common/msg/DebugEntity")

var ent : RosMirenaCommonEntity:
	get: return get_member(&"ent") as RosMsg
	set(v): set_member(&"ent", v)

var debug_id : int:
	get: return get_member(&"debug_id")
	set(v): set_member(&"debug_id", v)

var debug_real_position : RosGeometryMsgsPoint:
	get: return get_member(&"debug_real_position") as RosMsg
	set(v): set_member(&"debug_real_position", v)
