extends RosMsg
class_name RosSensorMsgsIlluminance

func _init():
	init("sensor_msgs/msg/Illuminance")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var illuminance : float:
	get: return get_member(&"illuminance")
	set(v): set_member(&"illuminance", v)

var variance : float:
	get: return get_member(&"variance")
	set(v): set_member(&"variance", v)

