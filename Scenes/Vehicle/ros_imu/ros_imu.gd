extends RigidBody3D

# --- Configuration ---
@export_group("ROS 2 Settings")
@export var imu_topic: String = "/sim/IMU"
@export var frame_id: String = "IMU"
@export var imu_rate: float = 100.0 

@export_group("Physical Constants")
@export var gravity_constant: float = 9.81 # Standard gravity

@export_group("Noise Model")
## Standard deviation for accelerometer white noise (m/s^2)
@export var accel_noise_std: float = 0.05
## Standard deviation for gyroscope white noise (rad/s)
@export var gyro_noise_std: float = 0.005
## Rate of change for the bias drift (Random Walk)
@export var bias_drift_std: float = 0.0001

# --- Internal State ---
var _imu_node: RosNode
var _imu_pub: RosPublisher
var _last_velocity: Vector3 = Vector3.ZERO
var _timer_accumulator: float = 0.0

# Dynamic Biases
var _accel_bias: Vector3 = Vector3.ZERO
var _gyro_bias: Vector3 = Vector3.ZERO

func _ready() -> void:
	_imu_node = RosNode.new()
	_imu_node.init("ImuNode")
	_imu_pub = _imu_node.create_publisher(imu_topic, "sensor_msgs/msg/Imu")

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var dt = state.step
	if dt <= 0: return
	
	_timer_accumulator += dt
	var target_period = 1.0 / imu_rate
	
	# Track velocity for acceleration calculation
	var current_velocity = state.linear_velocity
	var raw_accel_g = (current_velocity - _last_velocity) / dt
	_last_velocity = current_velocity

	if _timer_accumulator >= target_period:
		_timer_accumulator -= target_period 
		
		var global_ang_vel = state.angular_velocity
		var current_basis = state.transform.basis
		
		# 1. Proper Acceleration (Global Frame)
		var proper_accel_g = raw_accel_g + Vector3(0, gravity_constant, 0)
		
		# 2. Transform to LOCAL IMU Frame
		var local_accel = current_basis.inverse() * proper_accel_g
		var local_ang_vel = current_basis.inverse() * global_ang_vel
		
		# 3. APPLY NOISE MODEL
		var noisy_accel = _apply_imu_noise(local_accel, accel_noise_std, _accel_bias)
		var noisy_gyro = _apply_imu_noise(local_ang_vel, gyro_noise_std, _gyro_bias)
		
		# 4. Update Random Walk Biases (Simulates drift over time)
		_accel_bias += _get_vec3_noise(bias_drift_std)
		_gyro_bias += _get_vec3_noise(bias_drift_std)
		
		# 5. Publish
		_publish_imu_data(noisy_accel, noisy_gyro, state.transform.basis.get_rotation_quaternion())

func _apply_imu_noise(clean_data: Vector3, white_noise_std: float, current_bias: Vector3) -> Vector3:
	# Sensor = Truth + Bias + White Noise
	return clean_data + current_bias + _get_vec3_noise(white_noise_std)

func _get_vec3_noise(std_dev: float) -> Vector3:
	return Vector3(
		randfn(0.0, std_dev),
		randfn(0.0, std_dev),
		randfn(0.0, std_dev)
	)

func _publish_imu_data(accel: Vector3, ang_vel: Vector3, rot: Quaternion) -> void:
	var msg = RosSensorMsgsImu.new()
	msg.header.frame_id = frame_id
	msg.header.stamp = _imu_node.now()
	
	# Swizzle: Godot (Y-up) to ROS (Z-up)
	msg.linear_acceleration.x = accel.z
	msg.linear_acceleration.y = accel.x
	msg.linear_acceleration.z = accel.y
	
	msg.angular_velocity.x = ang_vel.z
	msg.angular_velocity.y = ang_vel.x
	msg.angular_velocity.z = ang_vel.y
	
	# Orientation Basis Reconstruction
	var g_basis = Basis(rot)
	var r_basis = Basis()
	r_basis[0] = Vector3(g_basis[2].z, g_basis[2].x, g_basis[2].y)
	r_basis[1] = Vector3(g_basis[0].z, g_basis[0].x, g_basis[0].y)
	r_basis[2] = Vector3(g_basis[1].z, g_basis[1].x, g_basis[1].y)
	
	var ros_quat = r_basis.get_rotation_quaternion()
	msg.orientation.x = ros_quat.x
	msg.orientation.y = ros_quat.y
	msg.orientation.z = ros_quat.z
	msg.orientation.w = ros_quat.w
	
	_imu_pub.publish(msg)
