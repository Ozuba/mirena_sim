extends RosMsg
class_name RosMirenaCommonCarParameters

func _init():
	init("mirena_common/msg/CarParameters")

var params : PackedFloat64Array:
	get: return get_member(&"params")
	set(v): set_member(&"params", v)

