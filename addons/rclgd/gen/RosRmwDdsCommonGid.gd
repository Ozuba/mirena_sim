extends RosMsg
class_name RosRmwDdsCommonGid

func _init():
	init("rmw_dds_common/msg/Gid")

var data : PackedByteArray:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

