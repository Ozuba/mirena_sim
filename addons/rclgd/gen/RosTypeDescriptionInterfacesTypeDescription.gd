extends RosMsg
class_name RosTypeDescriptionInterfacesTypeDescription

func _init():
	init("type_description_interfaces/msg/TypeDescription")

var type_description : RosTypeDescriptionInterfacesIndividualTypeDescription:
	get: return get_member(&"type_description") as RosMsg
	set(v): set_member(&"type_description", v)

var referenced_type_descriptions : Array:
	get: return get_member(&"referenced_type_descriptions")
	set(v): set_member(&"referenced_type_descriptions", v)

