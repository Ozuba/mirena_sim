extends RosMsg
class_name RosSensorMsgsMagneticField

func _init():
	init("sensor_msgs/msg/MagneticField")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var magnetic_field : RosGeometryMsgsVector3:
	get: return get_member(&"magnetic_field") as RosMsg
	set(v): set_member(&"magnetic_field", v)

var magnetic_field_covariance : PackedFloat64Array:
	get: return get_member(&"magnetic_field_covariance")
	set(v): set_member(&"magnetic_field_covariance", v)

