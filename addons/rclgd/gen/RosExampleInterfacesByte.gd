extends RosMsg
class_name RosExampleInterfacesByte

func _init():
	init("example_interfaces/msg/Byte")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

