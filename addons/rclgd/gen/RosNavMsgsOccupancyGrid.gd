extends RosMsg
class_name RosNavMsgsOccupancyGrid

func _init():
	init("nav_msgs/msg/OccupancyGrid")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var info : RosNavMsgsMapMetaData:
	get: return get_member(&"info") as RosMsg
	set(v): set_member(&"info", v)

var data : Array:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

