extends RosMsg
class_name RosMirenaCommonFlatPoseDist

func _init():
	init("mirena_common/msg/FlatPoseDist")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var mean : PackedFloat64Array:
	get: return get_member(&"mean")
	set(v): set_member(&"mean", v)

var covariance : PackedFloat64Array:
	get: return get_member(&"covariance")
	set(v): set_member(&"covariance", v)

