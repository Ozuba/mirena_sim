extends RosMsg
class_name RosExampleInterfacesEmpty

func _init():
	init("example_interfaces/msg/Empty")

var structure_needs_at_least_one_member : int:
	get: return get_member(&"structure_needs_at_least_one_member")
	set(v): set_member(&"structure_needs_at_least_one_member", v)

