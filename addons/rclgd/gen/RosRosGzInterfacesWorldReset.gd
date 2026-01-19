extends RosMsg
class_name RosRosGzInterfacesWorldReset

func _init():
	init("ros_gz_interfaces/msg/WorldReset")

var all : int:
	get: return get_member(&"all")
	set(v): set_member(&"all", v)

var time_only : int:
	get: return get_member(&"time_only")
	set(v): set_member(&"time_only", v)

var model_only : int:
	get: return get_member(&"model_only")
	set(v): set_member(&"model_only", v)

