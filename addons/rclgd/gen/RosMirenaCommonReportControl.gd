extends RosMsg
class_name RosMirenaCommonReportControl

func _init():
	init("mirena_common/msg/ReportControl")

var stamp : RosBuiltinInterfacesTime:
	get: return get_member(&"stamp") as RosMsg
	set(v): set_member(&"stamp", v)

var status : RosMirenaCommonNodeStatus:
	get: return get_member(&"status") as RosMsg
	set(v): set_member(&"status", v)

var progress : int:
	get: return get_member(&"progress")
	set(v): set_member(&"progress", v)

