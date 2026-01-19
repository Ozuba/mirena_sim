extends RosMsg
class_name RosTypeDescriptionInterfacesKeyValue

func _init():
	init("type_description_interfaces/msg/KeyValue")

var key : String:
	get: return get_member(&"key")
	set(v): set_member(&"key", v)

var value : String:
	get: return get_member(&"value")
	set(v): set_member(&"value", v)

