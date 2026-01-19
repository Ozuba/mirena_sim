extends RosMsg
class_name RosUniqueIdentifierMsgsUuid

func _init():
	init("unique_identifier_msgs/msg/UUID")

var uuid : PackedByteArray:
	get: return get_member(&"uuid")
	set(v): set_member(&"uuid", v)

