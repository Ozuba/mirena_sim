extends RosMsg
class_name RosGeometryMsgsTransformStamped

func _init():
	init("geometry_msgs/msg/TransformStamped")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var child_frame_id : String:
	get: return get_member(&"child_frame_id")
	set(v): set_member(&"child_frame_id", v)

var transform : RosGeometryMsgsTransform:
	get: return get_member(&"transform") as RosMsg
	set(v): set_member(&"transform", v)

