extends RosMsg
class_name RosExampleInterfacesWString

func _init():
	init("example_interfaces/msg/WString")

var data : Nil:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

