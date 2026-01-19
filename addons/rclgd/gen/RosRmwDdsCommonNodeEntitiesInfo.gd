extends RosMsg
class_name RosRmwDdsCommonNodeEntitiesInfo

func _init():
	init("rmw_dds_common/msg/NodeEntitiesInfo")

var node_namespace : String:
	get: return get_member(&"node_namespace")
	set(v): set_member(&"node_namespace", v)

var node_name : String:
	get: return get_member(&"node_name")
	set(v): set_member(&"node_name", v)

var reader_gid_seq : Array:
	get: return get_member(&"reader_gid_seq")
	set(v): set_member(&"reader_gid_seq", v)

var writer_gid_seq : Array:
	get: return get_member(&"writer_gid_seq")
	set(v): set_member(&"writer_gid_seq", v)

