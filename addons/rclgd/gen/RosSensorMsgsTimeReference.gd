extends RosMsg
class_name RosSensorMsgsTimeReference

func _init():
	init("sensor_msgs/msg/TimeReference")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var time_ref : RosBuiltinInterfacesTime:
	get: return get_member(&"time_ref") as RosMsg
	set(v): set_member(&"time_ref", v)

var source : String:
	get: return get_member(&"source")
	set(v): set_member(&"source", v)

