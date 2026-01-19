extends RosMsg
class_name RosSensorMsgsPointCloud

func _init():
	init("sensor_msgs/msg/PointCloud")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var points : Array:
	get: return get_member(&"points")
	set(v): set_member(&"points", v)

var channels : Array:
	get: return get_member(&"channels")
	set(v): set_member(&"channels", v)

