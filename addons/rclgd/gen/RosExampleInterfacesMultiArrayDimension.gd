extends RosMsg
class_name RosExampleInterfacesMultiArrayDimension

func _init():
	init("example_interfaces/msg/MultiArrayDimension")

var label : String:
	get: return get_member(&"label")
	set(v): set_member(&"label", v)

var size : int:
	get: return get_member(&"size")
	set(v): set_member(&"size", v)

var stride : int:
	get: return get_member(&"stride")
	set(v): set_member(&"stride", v)

