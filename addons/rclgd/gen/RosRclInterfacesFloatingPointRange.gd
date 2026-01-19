extends RosMsg
class_name RosRclInterfacesFloatingPointRange

func _init():
	init("rcl_interfaces/msg/FloatingPointRange")

var from_value : float:
	get: return get_member(&"from_value")
	set(v): set_member(&"from_value", v)

var to_value : float:
	get: return get_member(&"to_value")
	set(v): set_member(&"to_value", v)

var step : float:
	get: return get_member(&"step")
	set(v): set_member(&"step", v)

