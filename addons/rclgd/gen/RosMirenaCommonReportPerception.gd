extends RosMsg
class_name RosMirenaCommonReportPerception

func _init():
	init("mirena_common/msg/ReportPerception")

var stamp : RosBuiltinInterfacesTime:
	get: return get_member(&"stamp") as RosMsg
	set(v): set_member(&"stamp", v)

var status : RosMirenaCommonNodeStatus:
	get: return get_member(&"status") as RosMsg
	set(v): set_member(&"status", v)

var last_run_timestamp : RosBuiltinInterfacesTime:
	get: return get_member(&"last_run_timestamp") as RosMsg
	set(v): set_member(&"last_run_timestamp", v)

var last_run_cones_seen : int:
	get: return get_member(&"last_run_cones_seen")
	set(v): set_member(&"last_run_cones_seen", v)

