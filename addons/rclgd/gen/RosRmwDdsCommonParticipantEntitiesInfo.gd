extends RosMsg
class_name RosRmwDdsCommonParticipantEntitiesInfo

func _init():
	init("rmw_dds_common/msg/ParticipantEntitiesInfo")

var gid : RosRmwDdsCommonGid:
	get: return get_member(&"gid") as RosMsg
	set(v): set_member(&"gid", v)

var node_entities_info_seq : Array:
	get: return get_member(&"node_entities_info_seq")
	set(v): set_member(&"node_entities_info_seq", v)

