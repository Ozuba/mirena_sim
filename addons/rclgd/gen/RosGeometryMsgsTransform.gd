extends RosMsg
class_name RosGeometryMsgsTransform

func _init():
	init("geometry_msgs/msg/Transform")

var translation : RosGeometryMsgsVector3:
	get: return get_member(&"translation") as RosMsg
	set(v): set_member(&"translation", v)

var rotation : RosGeometryMsgsQuaternion:
	get: return get_member(&"rotation") as RosMsg
	set(v): set_member(&"rotation", v)

