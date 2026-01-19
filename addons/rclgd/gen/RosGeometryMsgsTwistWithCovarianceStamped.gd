extends RosMsg
class_name RosGeometryMsgsTwistWithCovarianceStamped

func _init():
	init("geometry_msgs/msg/TwistWithCovarianceStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var twist : RosGeometryMsgsTwistWithCovariance:
	get: return get_member(&"twist") as RosMsg
	set(v): set_member(&"twist", v)

