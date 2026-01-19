extends RosMsg
class_name RosTypeDescriptionInterfacesField

func _init():
	init("type_description_interfaces/msg/Field")

var name : String:
	get: return get_member(&"name")
	set(v): set_member(&"name", v)

var type : RosTypeDescriptionInterfacesFieldType:
	get: return get_member(&"type") as RosMsg
	set(v): set_member(&"type", v)

var default_value : String:
	get: return get_member(&"default_value")
	set(v): set_member(&"default_value", v)

