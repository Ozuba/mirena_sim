extends RosMsg
class_name RosExampleInterfacesFloat32

func _init():
	init("example_interfaces/msg/Float32")

var data : float:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

