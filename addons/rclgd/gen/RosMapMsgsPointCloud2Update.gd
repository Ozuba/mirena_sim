extends RosMsg
class_name RosMapMsgsPointCloud2Update

func _init():
	init("map_msgs/msg/PointCloud2Update")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var type : int:
	get: return get_member(&"type")
	set(v): set_member(&"type", v)

var points : RosSensorMsgsPointCloud2:
	get: return get_member(&"points") as RosMsg
	set(v): set_member(&"points", v)

