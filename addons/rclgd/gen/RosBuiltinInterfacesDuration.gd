extends RosMsg
class_name RosBuiltinInterfacesDuration

func _init():
	init("builtin_interfaces/msg/Duration")

var sec : int:
	get: return get_member(&"sec")
	set(v): set_member(&"sec", v)

var nanosec : int:
	get: return get_member(&"nanosec")
	set(v): set_member(&"nanosec", v)

