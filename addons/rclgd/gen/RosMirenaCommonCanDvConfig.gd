extends RosMsg
class_name RosMirenaCommonCanDvConfig

func _init():
	init("mirena_common/msg/CanDvConfig")

var multiplexer : int:
	get: return get_member(&"multiplexer")
	set(v): set_member(&"multiplexer", v)

var m0_val_mission_req : RosMirenaCommonMissionType:
	get: return get_member(&"m0_val_mission_req") as RosMsg
	set(v): set_member(&"m0_val_mission_req", v)

var m1_val_driverless_set_enabled : bool:
	get: return get_member(&"m1_val_driverless_set_enabled")
	set(v): set_member(&"m1_val_driverless_set_enabled", v)

