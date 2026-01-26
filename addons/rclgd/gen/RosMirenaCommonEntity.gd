extends RosMsg
class_name RosMirenaCommonEntity

func _init():
	init("mirena_common/msg/Entity")

var position : RosGeometryMsgsPoint:
	get: return get_member(&"position") as RosMsg
	set(v): set_member(&"position", v)

var type : String:
	get: return get_member(&"type")
	set(v): set_member(&"type", v)

