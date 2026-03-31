extends RosMsg
class_name RosPlotjugglerMsgsDataPoints

func _init():
	init("plotjuggler_msgs/msg/DataPoints")

var dictionary_uuid : int:
	get: return get_member(&"dictionary_uuid")
	set(v): set_member(&"dictionary_uuid", v)

var samples : Array:
	get: return get_member(&"samples")
	set(v): set_member(&"samples", v)

