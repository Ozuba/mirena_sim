extends RosMsg
class_name RosVisualizationMsgsInteractiveMarkerPose

func _init():
	init("visualization_msgs/msg/InteractiveMarkerPose")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var pose : RosGeometryMsgsPose:
	get: return get_member(&"pose") as RosMsg
	set(v): set_member(&"pose", v)

var name : String:
	get: return get_member(&"name")
	set(v): set_member(&"name", v)

