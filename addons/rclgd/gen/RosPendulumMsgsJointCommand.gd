extends RosMsg
class_name RosPendulumMsgsJointCommand

func _init():
	init("pendulum_msgs/msg/JointCommand")

var position : float:
	get: return get_member(&"position")
	set(v): set_member(&"position", v)

