extends RosMsg
class_name RosSensorMsgsMultiDofJointState

func _init():
	init("sensor_msgs/msg/MultiDOFJointState")

var header : RosStdMsgsHeader:
	get: return get_member(&"header") as RosMsg
	set(v): set_member(&"header", v)

var joint_names : PackedStringArray:
	get: return get_member(&"joint_names")
	set(v): set_member(&"joint_names", v)

var transforms : Array:
	get: return get_member(&"transforms")
	set(v): set_member(&"transforms", v)

var twist : Array:
	get: return get_member(&"twist")
	set(v): set_member(&"twist", v)

var wrench : Array:
	get: return get_member(&"wrench")
	set(v): set_member(&"wrench", v)

