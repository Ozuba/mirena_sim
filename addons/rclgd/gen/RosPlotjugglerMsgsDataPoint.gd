extends RosMsg
class_name RosPlotjugglerMsgsDataPoint

func _init():
	init("plotjuggler_msgs/msg/DataPoint")

var name_index : int:
	get: return get_member(&"name_index")
	set(v): set_member(&"name_index", v)

var stamp : float:
	get: return get_member(&"stamp")
	set(v): set_member(&"stamp", v)

var value : float:
	get: return get_member(&"value")
	set(v): set_member(&"value", v)

