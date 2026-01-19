extends RosMsg
class_name RosSensorMsgsRelativeHumidity

func _init():
	init("sensor_msgs/msg/RelativeHumidity")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var relative_humidity : float:
	get: return get_member(&"relative_humidity")
	set(v): set_member(&"relative_humidity", v)

var variance : float:
	get: return get_member(&"variance")
	set(v): set_member(&"variance", v)

