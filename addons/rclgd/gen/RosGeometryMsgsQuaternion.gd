extends RosMsg
class_name RosGeometryMsgsQuaternion

func _init():
	init("geometry_msgs/msg/Quaternion")

var x : float:
	get: return get_member(&"x")
	set(v): set_member(&"x", v)

var y : float:
	get: return get_member(&"y")
	set(v): set_member(&"y", v)

var z : float:
	get: return get_member(&"z")
	set(v): set_member(&"z", v)

var w : float:
	get: return get_member(&"w")
	set(v): set_member(&"w", v)

