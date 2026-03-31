extends RosMsg
class_name RosDataTamerMsgsSnapshot

func _init():
	init("data_tamer_msgs/msg/Snapshot")

var timestamp_nsec : int:
	get: return get_member(&"timestamp_nsec")
	set(v): set_member(&"timestamp_nsec", v)

var schema_hash : int:
	get: return get_member(&"schema_hash")
	set(v): set_member(&"schema_hash", v)

var active_mask : PackedByteArray:
	get: return get_member(&"active_mask")
	set(v): set_member(&"active_mask", v)

var payload : PackedByteArray:
	get: return get_member(&"payload")
	set(v): set_member(&"payload", v)

