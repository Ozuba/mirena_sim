extends RosMsg
class_name RosGeometryMsgsVelocityStamped

func _init():
	init("geometry_msgs/msg/VelocityStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var body_frame_id : String:
	get: return get_member(&"body_frame_id")
	set(v): set_member(&"body_frame_id", v)

var reference_frame_id : String:
	get: return get_member(&"reference_frame_id")
	set(v): set_member(&"reference_frame_id", v)

var velocity : RosGeometryMsgsTwist:
	get: return get_member(&"velocity") as RosMsg
	set(v): set_member(&"velocity", v)

