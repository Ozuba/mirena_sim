extends Node

var _ros_time := RosTime.new()
var _ros_publishers := MirenaRosBridge.new()

func get_ros_publishers() -> MirenaRosBridge:
	return _ros_publishers

func get_ros_time() -> RosTime:
	return _ros_time
