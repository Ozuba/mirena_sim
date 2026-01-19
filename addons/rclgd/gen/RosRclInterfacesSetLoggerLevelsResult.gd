extends RosMsg
class_name RosRclInterfacesSetLoggerLevelsResult

func _init():
	init("rcl_interfaces/msg/SetLoggerLevelsResult")

var successful : int:
	get: return get_member(&"successful")
	set(v): set_member(&"successful", v)

var reason : String:
	get: return get_member(&"reason")
	set(v): set_member(&"reason", v)

