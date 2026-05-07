extends RosMsg
class_name RosDataTamerMsgsSchemas

func _init():
	init("data_tamer_msgs/msg/Schemas")

var schemas : Array:
	get: return get_member(&"schemas")
	set(v): set_member(&"schemas", v)

