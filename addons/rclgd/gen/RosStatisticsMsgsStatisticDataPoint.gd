extends RosMsg
class_name RosStatisticsMsgsStatisticDataPoint

func _init():
	init("statistics_msgs/msg/StatisticDataPoint")

var data_type : int:
	get: return get_member(&"data_type")
	set(v): set_member(&"data_type", v)

var data : float:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

