extends RosMsg
class_name RosTf2MsgsTfMessage

func _init():
	init("tf2_msgs/msg/TFMessage")

var transforms : Array:
	get: return get_member(&"transforms")
	set(v): set_member(&"transforms", v)

