extends RosMsg
class_name RosMirenaCommonMissionStatus

func _init():
	init("mirena_common/msg/MissionStatus")

var mission_status : int:
	get: return get_member(&"mission_status")
	set(v): set_member(&"mission_status", v)

