extends RosMsg
class_name RosTrajectoryMsgsMultiDofJointTrajectory

func _init():
	init("trajectory_msgs/msg/MultiDOFJointTrajectory")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var joint_names : PackedStringArray:
	get: return get_member(&"joint_names")
	set(v): set_member(&"joint_names", v)

var points : Array:
	get: return get_member(&"points")
	set(v): set_member(&"points", v)

