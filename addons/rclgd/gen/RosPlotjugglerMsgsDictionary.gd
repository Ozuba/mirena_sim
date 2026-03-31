extends RosMsg
class_name RosPlotjugglerMsgsDictionary

func _init():
	init("plotjuggler_msgs/msg/Dictionary")

var dictionary_uuid : int:
	get: return get_member(&"dictionary_uuid")
	set(v): set_member(&"dictionary_uuid", v)

var names : PackedStringArray:
	get: return get_member(&"names")
	set(v): set_member(&"names", v)

