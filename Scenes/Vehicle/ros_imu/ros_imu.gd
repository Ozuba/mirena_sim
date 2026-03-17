extends Node3D
class_name RosImuPublisher

# --- Configuration ---
@export_group("ROS 2 Settings")
@export var imu_rate: float = 100.0 
@export var frame_id: String = "~/imu_link"
@export var parent_frame_id: String = "~/base_link"

@export_group("Physical Constants")
@export var gravity_constant: float = 9.81 

@export_group("Noise Model")
@export var accel_noise_std: float = 0.05
@export var gyro_noise_std: float = 0.005
@export var bias_drift_std: float = 0.0001

# --- ROS Components ---
var _node: RosNode
var _imu_pub: RosPublisher
var _tf_broadcaster: RosTfBroadcaster

# --- Internal State ---
var is_initialized: bool = false
var _last_velocity: Vector3 = Vector3.ZERO
var _timer_accumulator: float = 0.0
var _msg: RosSensorMsgsImu

# Dynamic Biases (Random Walk)
var _accel_bias: Vector3 = Vector3.ZERO
var _gyro_bias: Vector3 = Vector3.ZERO

func init(ros_ns: String) -> void:
	# 1. Initialize ROS Node and Components
	_node = RosNode.new()
	_node.init(name.to_snake_case(), ros_ns)
	_imu_pub = _node.create_publisher("~/data", "sensor_msgs/msg/Imu")
	_tf_broadcaster = _node.create_tf_broadcaster()
	

	_msg = RosSensorMsgsImu.new()
	
	is_initialized = true

func _physics_process(delta: float) -> void:
	if not is_initialized: return

	# --- TF BROADCASTING ---
	# Broadcast the IMU's mount position relative to the car every frame
	_tf_broadcaster.send_transform(transform, frame_id, parent_frame_id, false)

	# --- ACCEL / GYRO LOGIC ---
	# Since we are no longer a RigidBody, we sample velocity from our parent car
	var parent_body = get_parent() as RigidBody3D
	if not parent_body: return

	var dt = delta
	var current_velocity = parent_body.linear_velocity
	var raw_accel_g = (current_velocity - _last_velocity) / dt
	_last_velocity = current_velocity

	_timer_accumulator += dt
	if _timer_accumulator >= 1.0 / imu_rate:
		_timer_accumulator -= 1.0 / imu_rate 
		
		var current_basis = global_transform.basis
		var global_ang_vel = parent_body.angular_velocity
		
		# Proper Acceleration: raw + gravity
		var proper_accel_g = raw_accel_g + Vector3(0, gravity_constant, 0)
		
		# Transform to local sensor-space
		var local_accel = current_basis.inverse() * proper_accel_g
		var local_ang_vel = current_basis.inverse() * global_ang_vel
		
		# Apply Noise and Update Biases
		var noisy_accel = _apply_noise(local_accel, accel_noise_std, _accel_bias)
		var noisy_gyro = _apply_noise(local_ang_vel, gyro_noise_std, _gyro_bias)
		_accel_bias += _get_noise_vec(bias_drift_std)
		_gyro_bias += _get_noise_vec(bias_drift_std)
		
		_publish_imu(noisy_accel, noisy_gyro, current_basis.get_quaternion())

func _publish_imu(accel: Vector3, gyro: Vector3, rot: Quaternion) -> void:
	_msg.header.stamp = _node.now()
	_msg.header.frame_id = _node.get_namespace().trim_prefix("/").path_join(frame_id.trim_prefix("~/"))
	
	# --- Godot (Y-Up) to ROS (Z-Up / FLU) Swizzle ---
	_msg.linear_acceleration.x = accel.z
	_msg.linear_acceleration.y = -accel.x
	_msg.linear_acceleration.z = accel.y
	
	_msg.angular_velocity.x = gyro.z
	_msg.angular_velocity.y = -gyro.x
	_msg.angular_velocity.z = gyro.y
	
	# Orientation Conversion
	# Godot's world rotation converted to the ROS orientation standard
	var q_up_conv = Quaternion(0.5, 0.5, 0.5, 0.5) 
	var ros_quat = q_up_conv * rot
	
	_msg.orientation.x = ros_quat.x
	_msg.orientation.y = ros_quat.y
	_msg.orientation.z = ros_quat.z
	_msg.orientation.w = ros_quat.w
	
	_imu_pub.publish(_msg)


func _apply_noise(data: Vector3, std: float, bias: Vector3) -> Vector3:
	return data + bias + _get_noise_vec(std)

func _get_noise_vec(std: float) -> Vector3:
	return Vector3(randfn(0, std), randfn(0, std), randfn(0, std))
