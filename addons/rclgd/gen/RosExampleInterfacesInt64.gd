extends RosMsg
class_name RosExampleInterfacesInt64

func _init():
	init("example_interfaces/msg/Int64")

var data : int:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

