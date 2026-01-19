extends RosMsg
class_name RosSensorMsgsJointState

func _init():
	init("sensor_msgs/msg/JointState")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var name : PackedStringArray:
	get: return get_member(&"name")
	set(v): set_member(&"name", v)

var position : PackedFloat64Array:
	get: return get_member(&"position")
	set(v): set_member(&"position", v)

var velocity : PackedFloat64Array:
	get: return get_member(&"velocity")
	set(v): set_member(&"velocity", v)

var effort : PackedFloat64Array:
	get: return get_member(&"effort")
	set(v): set_member(&"effort", v)

