extends RefCounted
class_name PipelineSpoofer

var _owner: MirenaCar
var _consensus: ConsensusSpoof
var _perception: PerceptionSpoof
var _slam: SlamSpoof

var _car_state : RosMirenaCommonCar 
var _perception_msg : RosMirenaCommonEntityList
var _slam_map_msg : RosMirenaCommonEntityList

var _slam_cones: Array = [] # Seen cones

var _map_to_odom_tf: Transform3D
var _odom_to_cog_tf: Transform3D

const FIXED_FRAME: String = "map"

class ConsensusSpoof extends RefCounted:
	var node: RosNode
	var vv_car_estimate_pub: RosPublisher;
	var rv_car_estimate_pub: RosPublisher;
	var do_vv_spoof: bool = true;
	var do_rv_spoof: bool = false;
	var tf_broadcaster: RosTfBroadcaster;
	
	func _init(virtual_vehicle_topic: String, real_vehicle_topic: String) -> void:
		node = RosNode.new()
		node.init("consensus_spoof", "")

		vv_car_estimate_pub = node.create_publisher(virtual_vehicle_topic, "mirena_common/msg/Car")
		rv_car_estimate_pub = node.create_publisher(real_vehicle_topic, "mirena_common/msg/Car")
		tf_broadcaster = node.create_tf_broadcaster()

class PerceptionSpoof extends RefCounted:
	var node: RosNode
	var vv_perception_pub: RosPublisher;
	var rv_perception_pub: RosPublisher;
	var do_vv_spoof: bool = true;
	var do_rv_spoof: bool = false;
	
	func _init(virtual_perception_topic: String, real_perception_topic: String) -> void:
		node = RosNode.new()
		node.init("perception_spoof", "")

		vv_perception_pub = node.create_publisher(virtual_perception_topic, RosMirenaCommonEntityList.ROS_TYPE_NAME)
		rv_perception_pub = node.create_publisher(real_perception_topic, RosMirenaCommonEntityList.ROS_TYPE_NAME)


class SlamSpoof extends RefCounted:
	var node: RosNode
	var vv_car_state_pub: RosPublisher;
	var rv_car_state_pub: RosPublisher;
	var vv_slam_map_pub: RosPublisher;
	var rv_slam_map_pub: RosPublisher;
	var tf_broadcaster: RosTfBroadcaster;
	var do_vv_spoof: bool = true;
	var do_rv_spoof: bool = false;
	
	func _init(virtual_vehicle_topic: String, real_vehicle_topic: String, virtual_map_topic: String, real_map_topic: String) -> void:
		node = RosNode.new()
		node.init("slam_spoof", "")
		
		vv_car_state_pub = node.create_publisher(virtual_vehicle_topic, "mirena_common/msg/Car")
		rv_car_state_pub = node.create_publisher(real_vehicle_topic, "mirena_common/msg/Car")
		vv_slam_map_pub = node.create_publisher(virtual_map_topic, RosMirenaCommonEntityList.ROS_TYPE_NAME)
		rv_slam_map_pub = node.create_publisher(real_map_topic, RosMirenaCommonEntityList.ROS_TYPE_NAME)
		tf_broadcaster = node.create_tf_broadcaster()

func _init(owner: MirenaCar) -> void:
	_owner = owner
	_car_state = RosMirenaCommonCar.new()
	_perception_msg = RosMirenaCommonEntityList.new()
	_slam_map_msg = RosMirenaCommonEntityList.new()
	
	_perception = PerceptionSpoof.new("vcar/perception/entities", "car/perception/entities")
	_consensus = ConsensusSpoof.new("vcar/consensus/car", "car/consensus/car")
	_slam = SlamSpoof.new("vcar/slam/car", "car/slam/car", "vcar/slam/entities", "car/slam/entities")

func _update_car_state() -> void:
	var now = _consensus.node.now()
	_car_state.header.stamp = now
	
	var odom_transform : Transform3D = _owner.origin.inverse() * _owner.global_transform
	# 1. Pose and Dynamics
	_car_state.x = -odom_transform.origin.z
	_car_state.y = -odom_transform.origin.x
	_car_state.psi = odom_transform.basis.get_euler().y
	
	var local_vel = _owner.basis.inverse() * _owner.linear_velocity
	_car_state.u = -local_vel.z
	_car_state.v = -local_vel.x
	_car_state.omega = _owner.angular_velocity.y
	
	# 2. Covariance Setup (6x6 matrix flattened)
	# Indices for diagonal: x=0, y=7, psi=14, u=21, v=28, omega=35
	var cov = []
	cov.resize(36)
	for i in range(36):
		cov[i] = 0.0 # Initialize all to zero
		
	# Set Variances (Standard Deviation squared)
	# These values represent "how much we trust the simulator"
	cov[0]  = 0 # x variance (m^2)
	cov[7]  = 0  # y variance (m^2)
	cov[14] = 0 # psi variance (rad^2)
	cov[21] = 0  # u variance (m/s^2)
	cov[28] = 0  # v variance (m/s^2)
	cov[35] = 0  # omega variance (rad/s^2)
	
	_car_state.covariance = cov
	_map_to_odom_tf = Transform3D.IDENTITY
	_odom_to_cog_tf = odom_transform.translated(_owner.center_of_mass)

func _update_seen_cones() -> void:
	var cones = _owner.get_cones_in_sight(12.0)
	for cone in cones:
		if not _slam_cones.has(cone): _slam_cones.append(cone)
	_slam_cones = _slam_cones.filter(func(c): return is_instance_valid(c))
	
	# This is shit. we need an inertial frame asap lmao...
	_perception_msg.header.stamp = _perception.node.now()
	var _to_cog_tf = _owner.global_transform.inverse()
	_perception_msg.entities = cones.map(func(c): return _to_ent(_to_cog_tf, c))
	_slam_map_msg.header.stamp = _perception.node.now()
	_slam_map_msg.header.frame_id = FIXED_FRAME
	var _to_map_tf = _owner.origin.inverse()
	_slam_map_msg.entities = _slam_cones.map(func(c): return _to_ent(_to_map_tf, c))
	

static func _to_ent(transform: Transform3D, cone: Node3D) -> RosMirenaCommonEntity:
	var ent = RosMirenaCommonEntity.new()
	var pos =  transform * (cone.global_position)
	ent.type = cone.get_type_as_string()
	
	# ROS Swizzle: Forward=Z, Left=-X, Up=Y
	ent.position.x = -pos.z
	ent.position.y = -pos.x
	ent.position.z = pos.y
	return ent


func spoof() -> void:
	_update_car_state()
	_update_seen_cones()
	
	var now = _slam.node.now()
	if _consensus.do_vv_spoof:
		_car_state.header.frame_id = "vcar/odom"
		_car_state.child_frame_id = "vcar/cog"
		_consensus.vv_car_estimate_pub.publish(_car_state)
		_consensus.tf_broadcaster.send_transform(_odom_to_cog_tf, "vcar/cog", "vcar/odom", false, now)
	if _consensus.do_rv_spoof:
		_car_state.header.frame_id = "car/odom"
		_car_state.child_frame_id = "car/cog"
		_consensus.rv_car_estimate_pub.publish(_car_state)
		_consensus.tf_broadcaster.send_transform(_odom_to_cog_tf, "car/cog", "car/odom", false, now)

	
	if _perception.do_vv_spoof:
		_perception_msg.header.frame_id = "vcar/cog"
		_perception.vv_perception_pub.publish(_perception_msg)
	if _perception.do_rv_spoof:
		_perception_msg.header.frame_id = "car/cog"
		_perception.rv_perception_pub.publish(_perception_msg)
	
	# ------------------- SLAM --------------

	if _slam.do_vv_spoof:
		_car_state.header.frame_id = "vcar/odom"
		_car_state.child_frame_id = "vcar/cog"
		_slam.vv_car_state_pub.publish(_car_state)
		_slam.vv_slam_map_pub.publish(_slam_map_msg)
		_slam.tf_broadcaster.send_transform(_map_to_odom_tf, "vcar/odom", FIXED_FRAME, false, now)

	if _slam.do_rv_spoof:
		_car_state.header.frame_id = "car/odom"
		_car_state.child_frame_id = "car/cog"
		_slam.rv_car_state_pub.publish(_car_state)
		_slam.rv_slam_map_pub.publish(_slam_map_msg)
		_slam.tf_broadcaster.send_transform(_map_to_odom_tf, "car/odom", FIXED_FRAME, false, now)


func reset():
	_slam_cones = []
