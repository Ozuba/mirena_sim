extends RosMsg
class_name RosNavMsgsGridCells

func _init():
	init("nav_msgs/msg/GridCells")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var cell_width : float:
	get: return get_member(&"cell_width")
	set(v): set_member(&"cell_width", v)

var cell_height : float:
	get: return get_member(&"cell_height")
	set(v): set_member(&"cell_height", v)

var cells : Array:
	get: return get_member(&"cells")
	set(v): set_member(&"cells", v)

