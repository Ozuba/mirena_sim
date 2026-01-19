extends RosMsg
class_name RosLifecycleMsgsState

func _init():
	init("lifecycle_msgs/msg/State")

var id : int:
	get: return get_member(&"id")
	set(v): set_member(&"id", v)

var label : String:
	get: return get_member(&"label")
	set(v): set_member(&"label", v)

