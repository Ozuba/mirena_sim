extends RosMsg
class_name RosShapeMsgsPlane

func _init():
	init("shape_msgs/msg/Plane")

var coef : PackedFloat64Array:
	get: return get_member(&"coef")
	set(v): set_member(&"coef", v)

