extends RosMsg
class_name RosTrajectoryMsgsMultiDofJointTrajectoryPoint

func _init():
	init("trajectory_msgs/msg/MultiDOFJointTrajectoryPoint")

var transforms : Array:
	get: return get_member(&"transforms")
	set(v): set_member(&"transforms", v)

var velocities : Array:
	get: return get_member(&"velocities")
	set(v): set_member(&"velocities", v)

var accelerations : Array:
	get: return get_member(&"accelerations")
	set(v): set_member(&"accelerations", v)

var time_from_start : RosBuiltinInterfacesDuration:
	get: return get_member(&"time_from_start") as RosMsg
	set(v): set_member(&"time_from_start", v)

