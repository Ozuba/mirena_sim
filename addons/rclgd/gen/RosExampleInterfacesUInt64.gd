extends RosMsg
class_name RosExampleInterfacesUInt64

func _init():
	init("example_interfaces/msg/UInt64")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

