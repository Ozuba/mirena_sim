extends RigidBody3D

# --- Configuration ---
@export var imu_topic: String = "/sim/IMU"
@export var frame_id: String = "IMU"
@export var imu_rate: float = 100.0 # Target publishing rate in Hz
@export var gravity_constant: float = 9.80665

# --- Noise Configuration (Matches standard MEMS IMU) ---
@export var accel_noise_std: float = 0.01 # m/s^2
@export var gyro_noise_std: float = 0.001 # rad/s

# --- Internal State ---
var _imu_node: RosNode
var _imu_pub: RosPublisher
var _last_velocity: Vector3 = Vector3.ZERO
var _timer_accumulator: float = 0.0

func _ready() -> void:
	_imu_node = RosNode.new()
	_imu_node.init("ImuNode")
	_imu_pub = _imu_node.create_publisher(imu_topic, "sensor_msgs/msg/Imu")

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var dt = state.step
	if dt <= 0: return
	
	# 1. Update the rate accumulator
	_timer_accumulator += dt
	var target_period = 1.0 / imu_rate
	
	# Calculate global proper acceleration regardless of rate (for velocity tracking)
	var current_velocity = state.linear_velocity
	var raw_accel_g = (current_velocity - _last_velocity) / dt
	_last_velocity = current_velocity

	# 2. Only publish if enough time has passed to match imu_rate
	if _timer_accumulator >= target_period:
		_timer_accumulator -= target_period # Reset but keep the remainder for precision
		
		var global_ang_vel = state.angular_velocity
		var current_basis = state.transform.basis
		
		# 3. Proper Acceleration (Global Frame)
		var proper_accel_g = raw_accel_g + Vector3(0, gravity_constant, 0)
		
		# 4. Transform to LOCAL IMU Frame
		var local_accel = current_basis.inverse() * proper_accel_g
		var local_ang_vel = current_basis.inverse() * global_ang_vel
		
		# 5. Add Gaussian Noise (Box-Muller)
		local_accel += _get_vec3_noise(accel_noise_std)
		local_ang_vel += _get_vec3_noise(gyro_noise_std)
		
		# 6. Publish
		_publish_imu_data(local_accel, local_ang_vel, state.transform.basis.get_rotation_quaternion())

# Helper for Gaussian Noise
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
