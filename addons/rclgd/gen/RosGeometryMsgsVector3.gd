extends RosMsg
class_name RosGeometryMsgsVector3

func _init():
	init("geometry_msgs/msg/Vector3")

var x : float:
	get: return get_member(&"x")
	set(v): set_member(&"x", v)

var y : float:
	get: return get_member(&"y")
	set(v): set_member(&"y", v)

var z : float:
	get: return get_member(&"z")
	set(v): set_member(&"z", v)

