extends Node

var _ros_time: RosTime = RosTime.new()

func _ready() -> void:
	print("updating time every x ms: ", _ros_time.get_update_period())
