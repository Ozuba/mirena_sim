extends RosMsg
class_name RosExampleInterfacesUInt64MultiArray

func _init():
	init("example_interfaces/msg/UInt64MultiArray")

var layout : RosExampleInterfacesMultiArrayLayout:
	get: return get_member(&"layout") as RosMsg
	set(v): set_member(&"layout", v)

var data : Array:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

