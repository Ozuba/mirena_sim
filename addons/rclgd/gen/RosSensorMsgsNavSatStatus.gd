extends RosMsg
class_name RosSensorMsgsNavSatStatus

func _init():
	init("sensor_msgs/msg/NavSatStatus")

var status : int:
	get: return get_member(&"status")
	set(v): set_member(&"status", v)

var service : int:
	get: return get_member(&"service")
	set(v): set_member(&"service", v)

