extends RosMsg
class_name RosVisualizationMsgsInteractiveMarkerInit

func _init():
	init("visualization_msgs/msg/InteractiveMarkerInit")

var server_id : String:
	get: return get_member(&"server_id")
	set(v): set_member(&"server_id", v)

var seq_num : int:
	get: return get_member(&"seq_num")
	set(v): set_member(&"seq_num", v)

var markers : Array:
	get: return get_member(&"markers")
	set(v): set_member(&"markers", v)

