extends RosMsg
class_name RosSensorMsgsNavSatFix

func _init():
	init("sensor_msgs/msg/NavSatFix")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var status : RosSensorMsgsNavSatStatus:
	get: return get_member(&"status") as RosMsg
	set(v): set_member(&"status", v)

var latitude : float:
	get: return get_member(&"latitude")
	set(v): set_member(&"latitude", v)

var longitude : float:
	get: return get_member(&"longitude")
	set(v): set_member(&"longitude", v)

var altitude : float:
	get: return get_member(&"altitude")
	set(v): set_member(&"altitude", v)

var position_covariance : PackedFloat64Array:
	get: return get_member(&"position_covariance")
	set(v): set_member(&"position_covariance", v)

var position_covariance_type : int:
	get: return get_member(&"position_covariance_type")
	set(v): set_member(&"position_covariance_type", v)

