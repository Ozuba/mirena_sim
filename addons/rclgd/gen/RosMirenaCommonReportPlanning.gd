extends RosMsg
class_name RosMirenaCommonReportPlanning

func _init():
	init("mirena_common/msg/ReportPlanning")

var stamp : RosBuiltinInterfacesTime:
	get: return get_member(&"stamp") as RosMsg
	set(v): set_member(&"stamp", v)

var status : RosMirenaCommonNodeStatus:
	get: return get_member(&"status") as RosMsg
	set(v): set_member(&"status", v)

var last_update_timestamp : RosBuiltinInterfacesTime:
	get: return get_member(&"last_update_timestamp") as RosMsg
	set(v): set_member(&"last_update_timestamp", v)

var knows_track_start : bool:
	get: return get_member(&"knows_track_start")
	set(v): set_member(&"knows_track_start", v)

var track_start : RosGeometryMsgsVector3:
	get: return get_member(&"track_start") as RosMsg
	set(v): set_member(&"track_start", v)

var knows_track_end : bool:
	get: return get_member(&"knows_track_end")
	set(v): set_member(&"knows_track_end", v)

var track_end : RosGeometryMsgsVector3:
	get: return get_member(&"track_end") as RosMsg
	set(v): set_member(&"track_end", v)

