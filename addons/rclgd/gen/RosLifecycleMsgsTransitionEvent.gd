extends RosMsg
class_name RosLifecycleMsgsTransitionEvent

func _init():
	init("lifecycle_msgs/msg/TransitionEvent")

var timestamp : int:
	get: return get_member(&"timestamp")
	set(v): set_member(&"timestamp", v)

var transition : RosLifecycleMsgsTransition:
	get: return get_member(&"transition") as RosMsg
	set(v): set_member(&"transition", v)

var start_state : RosLifecycleMsgsState:
	get: return get_member(&"start_state") as RosMsg
	set(v): set_member(&"start_state", v)

var goal_state : RosLifecycleMsgsState:
	get: return get_member(&"goal_state") as RosMsg
	set(v): set_member(&"goal_state", v)

