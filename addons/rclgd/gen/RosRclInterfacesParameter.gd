extends RosMsg
class_name RosRclInterfacesParameter

func _init():
	init("rcl_interfaces/msg/Parameter")

var name : String:
	get: return get_member(&"name")
	set(v): set_member(&"name", v)

var value : RosRclInterfacesParameterValue:
	get: return get_member(&"value") as RosMsg
	set(v): set_member(&"value", v)

