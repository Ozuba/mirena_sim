extends RosMsg
class_name RosRclInterfacesListParametersResult

func _init():
	init("rcl_interfaces/msg/ListParametersResult")

var names : PackedStringArray:
	get: return get_member(&"names")
	set(v): set_member(&"names", v)

var prefixes : PackedStringArray:
	get: return get_member(&"prefixes")
	set(v): set_member(&"prefixes", v)

