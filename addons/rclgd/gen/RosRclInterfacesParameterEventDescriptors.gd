extends RosMsg
class_name RosRclInterfacesParameterEventDescriptors

func _init():
	init("rcl_interfaces/msg/ParameterEventDescriptors")

var new_parameters : Array:
	get: return get_member(&"new_parameters")
	set(v): set_member(&"new_parameters", v)

var changed_parameters : Array:
	get: return get_member(&"changed_parameters")
	set(v): set_member(&"changed_parameters", v)

var deleted_parameters : Array:
	get: return get_member(&"deleted_parameters")
	set(v): set_member(&"deleted_parameters", v)

