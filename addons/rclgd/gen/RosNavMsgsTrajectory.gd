extends RosMsg
class_name RosNavMsgsTrajectory

func _init():
	init("nav_msgs/msg/Trajectory")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var points : Array:
	get: return get_member(&"points")
	set(v): set_member(&"points", v)

