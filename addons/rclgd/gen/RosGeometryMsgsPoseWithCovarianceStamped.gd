extends RosMsg
class_name RosGeometryMsgsPoseWithCovarianceStamped

func _init():
	init("geometry_msgs/msg/PoseWithCovarianceStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var pose : RosGeometryMsgsPoseWithCovariance:
	get: return get_member(&"pose") as RosMsg
	set(v): set_member(&"pose", v)

