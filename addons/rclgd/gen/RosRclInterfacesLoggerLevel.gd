extends RosMsg
class_name RosRclInterfacesLoggerLevel

func _init():
	init("rcl_interfaces/msg/LoggerLevel")

var name : String:
	get: return get_member(&"name")
	set(v): set_member(&"name", v)

var level : int:
	get: return get_member(&"level")
	set(v): set_member(&"level", v)

