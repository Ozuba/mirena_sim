extends RosMsg
class_name RosLifecycleMsgsTransition

func _init():
	init("lifecycle_msgs/msg/Transition")

var id : int:
	get: return get_member(&"id")
	set(v): set_member(&"id", v)

var label : String:
	get: return get_member(&"label")
	set(v): set_member(&"label", v)

