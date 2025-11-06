extends Node

var _ros_time := RosTime.new()
var _ros_publishers := MirenaRosBridge.new()
var _ros_publishers_disable : Dictionary[PublisherType, bool]

enum PublisherType {
	CarState,
	FullTrackCurve,
	SlamEntities,
	InferredControl,
	PerceptionCones
}

func set_publisher_enabled(pub: PublisherType, enable: bool) -> void:
	_ros_publishers_disable.set(pub, not enable)

func is_publisher_enabled(pub: PublisherType) -> bool:
	return _ros_publishers_disable.get(pub) != true

func enable_all_pub() -> void:
	_ros_publishers_disable.clear()

func disable_all_pub() -> void:
	for pub in PublisherType.values():
		set_publisher_enabled(pub, false)

func publish_car_state(pos: Vector3, rot: Vector3, lin_speed: Vector3, ang_speed: Vector3, lin_accel: Vector3, ang_accel: Vector3) -> void:
	if is_publisher_enabled(PublisherType.CarState):
		_ros_publishers.publish_car_state(pos, rot, lin_speed, ang_speed, lin_accel, ang_accel)

func publish_full_track_curve(curve: Curve3D) -> void:
	if is_publisher_enabled(PublisherType.FullTrackCurve):
		_ros_publishers.publish_full_track_curve(curve)

func publish_slam_entities(entity_array: Array) -> void:
	if is_publisher_enabled(PublisherType.SlamEntities):
		_ros_publishers.publish_slam_entities(entity_array)

func publish_inferred_control(gas: float, steer: float) -> void:
	if is_publisher_enabled(PublisherType.InferredControl):
		_ros_publishers.publish_inferred_control(gas, steer)

func publish_perception_entities(entity_array: Array) -> void:
	if is_publisher_enabled(PublisherType.PerceptionCones):
		_ros_publishers.publish_perception_entities(entity_array)

func get_ros_time() -> RosTime:
	return _ros_time

func _physics_process(_delta: float) -> void:
	_spin_all()

func _spin_all() -> void:
	_ros_time.spin()
	_ros_publishers.spin()
