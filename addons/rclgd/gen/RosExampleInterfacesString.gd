extends RosMsg
class_name RosExampleInterfacesString

func _init():
	init("example_interfaces/msg/String")

var data : String:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

