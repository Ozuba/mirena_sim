extends RosMsg
class_name RosSensorMsgsTemperature

func _init():
	init("sensor_msgs/msg/Temperature")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var temperature : float:
	get: return get_member(&"temperature")
	set(v): set_member(&"temperature", v)

var variance : float:
	get: return get_member(&"variance")
	set(v): set_member(&"variance", v)

