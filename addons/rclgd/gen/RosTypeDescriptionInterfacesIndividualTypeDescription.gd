extends RosMsg
class_name RosTypeDescriptionInterfacesIndividualTypeDescription

func _init():
	init("type_description_interfaces/msg/IndividualTypeDescription")

var type_name : String:
	get: return get_member(&"type_name")
	set(v): set_member(&"type_name", v)

var fields : Array:
	get: return get_member(&"fields")
	set(v): set_member(&"fields", v)

