extends RosMsg
class_name RosSensorMsgsJoyFeedback

func _init():
	init("sensor_msgs/msg/JoyFeedback")

var type : int:
	get: return get_member(&"type")
	set(v): set_member(&"type", v)

var id : int:
	get: return get_member(&"id")
	set(v): set_member(&"id", v)

var intensity : float:
	get: return get_member(&"intensity")
	set(v): set_member(&"intensity", v)

