extends RosMsg
class_name RosSensorMsgsCompressedImage

func _init():
	init("sensor_msgs/msg/CompressedImage")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var format : String:
	get: return get_member(&"format")
	set(v): set_member(&"format", v)

var data : PackedByteArray:
	get: return get_member(&"data")
	set(v): set_member(&"data", v)

