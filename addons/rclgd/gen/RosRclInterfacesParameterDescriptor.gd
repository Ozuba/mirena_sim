extends RosMsg
class_name RosRclInterfacesParameterDescriptor

func _init():
	init("rcl_interfaces/msg/ParameterDescriptor")

var name : String:
	get: return get_member(&"name")
	set(v): set_member(&"name", v)

var type : int:
	get: return get_member(&"type")
	set(v): set_member(&"type", v)

var description : String:
	get: return get_member(&"description")
	set(v): set_member(&"description", v)

var additional_constraints : String:
	get: return get_member(&"additional_constraints")
	set(v): set_member(&"additional_constraints", v)

var read_only : int:
	get: return get_member(&"read_only")
	set(v): set_member(&"read_only", v)

var dynamic_typing : int:
	get: return get_member(&"dynamic_typing")
	set(v): set_member(&"dynamic_typing", v)

