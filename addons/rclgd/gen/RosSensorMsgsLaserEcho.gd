extends RosMsg
class_name RosSensorMsgsLaserEcho

func _init():
	init("sensor_msgs/msg/LaserEcho")

var echoes : PackedFloat32Array:
	get: return get_member(&"echoes")
	set(v): set_member(&"echoes", v)

