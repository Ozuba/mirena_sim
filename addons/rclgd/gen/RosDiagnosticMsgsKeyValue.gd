extends RosMsg
class_name RosDiagnosticMsgsKeyValue

func _init():
	init("diagnostic_msgs/msg/KeyValue")

var key : String:
	get: return get_member(&"key")
	set(v): set_member(&"key", v)

var value : String:
	get: return get_member(&"value")
	set(v): set_member(&"value", v)

