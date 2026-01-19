extends RosMsg
class_name RosExampleInterfacesChar

func _init():
	init("example_interfaces/msg/Char")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

