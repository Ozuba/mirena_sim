extends RosMsg
class_name RosExampleInterfacesByteMultiArray

func _init():
	init("example_interfaces/msg/ByteMultiArray")

var layout : RosExampleInterfacesMultiArrayLayout:
	get: return get_member(&"layout") as RosMsg
	set(v): set_member(&"layout", v)

var data : PackedByteArray:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

