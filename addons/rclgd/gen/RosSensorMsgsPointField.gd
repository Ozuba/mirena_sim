extends RosMsg
class_name RosSensorMsgsPointField

func _init():
	init("sensor_msgs/msg/PointField")

var name : String:
	get: return get_member(&"name")
	set(v): set_member(&"name", v)

var offset : int:
	get: return get_member(&"offset")
	set(v): set_member(&"offset", v)

var datatype : int:
	get: return get_member(&"datatype")
	set(v): set_member(&"datatype", v)

var count : int:
	get: return get_member(&"count")
	set(v): set_member(&"count", v)

