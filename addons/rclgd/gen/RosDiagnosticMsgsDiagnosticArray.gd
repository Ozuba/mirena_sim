extends RosMsg
class_name RosDiagnosticMsgsDiagnosticArray

func _init():
	init("diagnostic_msgs/msg/DiagnosticArray")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var status : Array:
	get: return get_member(&"status")
	set(v): set_member(&"status", v)

