extends RosMsg
class_name RosMirenaCommonCanDvInfo

func _init():
	init("mirena_common/msg/CanDvInfo")

var mission_status : RosMirenaCommonMissionStatus:
	get: return get_member(&"mission_status") as RosMsg
	set(v): set_member(&"mission_status", v)

var mission : RosMirenaCommonMissionType:
	get: return get_member(&"mission") as RosMsg
	set(v): set_member(&"mission", v)

var cones_count_actual : int:
	get: return get_member(&"cones_count_actual")
	set(v): set_member(&"cones_count_actual", v)

var cones_count_total : int:
	get: return get_member(&"cones_count_total")
	set(v): set_member(&"cones_count_total", v)

var lap_counter : int:
	get: return get_member(&"lap_counter")
	set(v): set_member(&"lap_counter", v)

