extends RosMsg
class_name RosTf2MsgsTf2Error

func _init():
	init("tf2_msgs/msg/TF2Error")

var error : int:
	get: return get_member(&"error")
	set(v): set_member(&"error", v)

var error_string : String:
	get: return get_member(&"error_string")
	set(v): set_member(&"error_string", v)

