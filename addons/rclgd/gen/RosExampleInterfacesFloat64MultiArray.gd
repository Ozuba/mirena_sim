extends RosMsg
class_name RosExampleInterfacesFloat64MultiArray

func _init():
	init("example_interfaces/msg/Float64MultiArray")

var layout : RosExampleInterfacesMultiArrayLayout:
	get: return get_member(&"layout") as RosMsg
	set(v): set_member(&"layout", v)

var data : PackedFloat64Array:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

