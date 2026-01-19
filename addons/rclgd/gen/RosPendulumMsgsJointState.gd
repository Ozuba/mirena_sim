extends RosMsg
class_name RosPendulumMsgsJointState

func _init():
	init("pendulum_msgs/msg/JointState")

var position : float:
	get: return get_member(&"position")
	set(v): set_member(&"position", v)

var velocity : float:
	get: return get_member(&"velocity")
	set(v): set_member(&"velocity", v)

var effort : float:
	get: return get_member(&"effort")
	set(v): set_member(&"effort", v)

