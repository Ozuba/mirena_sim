extends RosMsg
class_name RosStatisticsMsgsStatisticDataType

func _init():
	init("statistics_msgs/msg/StatisticDataType")

var structure_needs_at_least_one_member : int:
	get: return get_member(&"structure_needs_at_least_one_member")
	set(v): set_member(&"structure_needs_at_least_one_member", v)

