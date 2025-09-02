extends Node

var _ros_time := RosTime.new()
var _ros_publishers := MirenaRosBridge.new()

func get_ros_publishers() -> MirenaRosBridge:
	return _ros_publishers

func get_ros_time() -> RosTime:
	return _ros_time

func _process(_delta: float) -> void:
	_spin_all()

func _spin_all() -> void:
	_ros_time.spin()
	_ros_publishers.spin()
