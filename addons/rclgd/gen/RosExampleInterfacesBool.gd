extends RosMsg
class_name RosExampleInterfacesBool

func _init():
	init("example_interfaces/msg/Bool")

var data : bool:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

