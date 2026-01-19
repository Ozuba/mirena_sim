extends RosMsg
class_name RosGeometryMsgsQuaternionStamped

func _init():
	init("geometry_msgs/msg/QuaternionStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var quaternion : RosGeometryMsgsQuaternion:
	get: return get_member(&"quaternion") as RosMsg
	set(v): set_member(&"quaternion", v)

