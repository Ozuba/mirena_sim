extends RosMsg
class_name RosExampleInterfacesFloat64

func _init():
	init("example_interfaces/msg/Float64")

var data : float:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

