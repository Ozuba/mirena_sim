extends RosMsg
class_name RosSensorMsgsJoy

func _init():
	init("sensor_msgs/msg/Joy")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var axes : PackedFloat32Array:
	get: return get_member(&"axes")
	set(v): set_member(&"axes", v)

var buttons : Array:
	get: return get_member(&"buttons")
	set(v): set_member(&"buttons", v)

