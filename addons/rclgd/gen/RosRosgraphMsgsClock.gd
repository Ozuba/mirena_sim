extends RosMsg
class_name RosRosgraphMsgsClock

func _init():
	init("rosgraph_msgs/msg/Clock")

var clock : RosBuiltinInterfacesTime:
	get: return get_member(&"clock") as RosMsg
	set(v): set_member(&"clock", v)

