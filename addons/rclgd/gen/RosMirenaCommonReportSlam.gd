extends RosMsg
class_name RosMirenaCommonReportSlam

func _init():
	init("mirena_common/msg/ReportSlam")

var stamp : RosBuiltinInterfacesTime:
	get: return get_member(&"stamp") as RosMsg
	set(v): set_member(&"stamp", v)

var status : RosMirenaCommonNodeStatus:
	get: return get_member(&"status") as RosMsg
	set(v): set_member(&"status", v)

var last_update_timestamp : RosBuiltinInterfacesTime:
	get: return get_member(&"last_update_timestamp") as RosMsg
	set(v): set_member(&"last_update_timestamp", v)

var last_update_total_landmark_count : int:
	get: return get_member(&"last_update_total_landmark_count")
	set(v): set_member(&"last_update_total_landmark_count", v)

var last_update_ms_elapsed : float:
	get: return get_member(&"last_update_ms_elapsed")
	set(v): set_member(&"last_update_ms_elapsed", v)

