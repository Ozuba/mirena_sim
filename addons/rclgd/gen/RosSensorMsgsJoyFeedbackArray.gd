extends RosMsg
class_name RosSensorMsgsJoyFeedbackArray

func _init():
	init("sensor_msgs/msg/JoyFeedbackArray")

var array : Array:
	get: return get_member(&"array")
	set(v): set_member(&"array", v)

