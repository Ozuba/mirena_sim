extends RosMsg
class_name RosTurtlesimColor

func _init():
	init("turtlesim/msg/Color")

var r : int:
	get: return get_member(&"r")
	set(v): set_member(&"r", v)

var g : int:
	get: return get_member(&"g")
	set(v): set_member(&"g", v)

var b : int:
	get: return get_member(&"b")
	set(v): set_member(&"b", v)

