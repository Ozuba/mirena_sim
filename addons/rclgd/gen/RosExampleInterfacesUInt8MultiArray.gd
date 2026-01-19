extends RosMsg
class_name RosExampleInterfacesUInt8MultiArray

func _init():
	init("example_interfaces/msg/UInt8MultiArray")

var layout : RosExampleInterfacesMultiArrayLayout:
	get: return get_member(&"layout") as RosMsg
	set(v): set_member(&"layout", v)

var data : PackedByteArray:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

