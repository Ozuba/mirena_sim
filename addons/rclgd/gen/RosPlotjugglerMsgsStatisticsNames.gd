extends RosMsg
class_name RosPlotjugglerMsgsStatisticsNames

func _init():
	init("plotjuggler_msgs/msg/StatisticsNames")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var names : PackedStringArray:
	get: return get_member(&"names")
	set(v): set_member(&"names", v)

var names_version : int:
	get: return get_member(&"names_version")
	set(v): set_member(&"names_version", v)

