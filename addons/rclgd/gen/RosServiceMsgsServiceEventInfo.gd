extends RosMsg
class_name RosServiceMsgsServiceEventInfo

func _init():
	init("service_msgs/msg/ServiceEventInfo")

var event_type : int:
	get: return get_member(&"event_type")
	set(v): set_member(&"event_type", v)

var stamp : RosBuiltinInterfacesTime:
	get: return get_member(&"stamp") as RosMsg
	set(v): set_member(&"stamp", v)

var client_gid : PackedByteArray:
	get: return get_member(&"client_gid")
	set(v): set_member(&"client_gid", v)

var sequence_number : int:
	get: return get_member(&"sequence_number")
	set(v): set_member(&"sequence_number", v)

