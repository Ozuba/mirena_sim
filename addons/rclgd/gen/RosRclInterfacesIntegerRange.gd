extends RosMsg
class_name RosRclInterfacesIntegerRange

func _init():
	init("rcl_interfaces/msg/IntegerRange")

var from_value : int:
	get: return get_member(&"from_value")
	set(v): set_member(&"from_value", v)

var to_value : int:
	get: return get_member(&"to_value")
	set(v): set_member(&"to_value", v)

var step : int:
	get: return get_member(&"step")
	set(v): set_member(&"step", v)

