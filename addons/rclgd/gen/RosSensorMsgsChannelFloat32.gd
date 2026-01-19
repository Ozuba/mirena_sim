extends RosMsg
class_name RosSensorMsgsChannelFloat32

func _init():
	init("sensor_msgs/msg/ChannelFloat32")

var name : String:
	get: return get_member(&"name")
	set(v): set_member(&"name", v)

var values : PackedFloat32Array:
	get: return get_member(&"values")
	set(v): set_member(&"values", v)

