extends RosNode3D


# --- Configuration ---
@export var imu_topic: String = "/imu/data"
@export var gravity_constant: float = 9.80665
@export var linear_acceleration_stdev: float = 0.01 # Noise simulation

# --- Internal State ---
var _imu_node: RosNode
var _imu_pub: RosPublisher
var _last_velocity: Vector3 = Vector3.ZERO
var _last_pos: Vector3 = Vector3.ZERO
var _last_quat: Quaternion = Quaternion.IDENTITY

func _ready() -> void:
	# Initialize the publisher using your GDExtension RosNode
	# Assuming RosNode3D has access to the internal RosNode or rclgd singleton
	_imu_node = RosNode.new()
	_imu_node.init("ImuNode")
	_imu_pub = _imu_node.create_publisher("sim/IMU", "sensor_msgs/msg/Imu")
	
	_last_pos = global_transform.origin
	_last_quat = global_transform.basis.get_rotation_quaternion()

func _physics_process(delta: float) -> void:
	if delta <= 0: return
	
	var current_tf = global_transform
	var current_pos = current_tf.origin
	var current_quat = current_tf.basis.get_rotation_quaternion()
	
	# 1. Linear Acceleration (Proper Acceleration)
	# velocity = ds/dt
	var current_velocity = (current_pos - _last_pos) / delta
	# accel = dv/dt
	var accel = (current_velocity - _last_velocity) / delta
	
	# IMUs measure proper acceleration (add gravity vector in Godot Y-up)
	accel.y += gravity_constant
	
	# 2. Angular Velocity
	# q_delta = q_curr * inv(q_prev)
	var q_diff = current_quat * _last_quat.inverse()
	var ang_vel = q_diff.get_euler() / delta
	
	# 3. Publish Message
	_publish_imu_data(accel, ang_vel, current_quat)
	
	# Store state for next frame
	_last_pos = current_pos
	_last_velocity = current_velocity
	_last_quat = current_quat

func _publish_imu_data(accel: Vector3, ang_vel: Vector3, rot: Quaternion) -> void:
	var msg = RosSensorMsgsImu.new()
	msg.header.frame_id = frame_id
	msg.header.stamp = RosNode.new().now() # Using your C++ RosNode time
	
	# --- Coordinate Swizzle: Godot (Y-up) to ROS (X-Forward / Z-up) ---
	# Linear Accel: -Z_g -> X_r, -X_g -> Y_r, Y_g -> Z_r
	msg.linear_acceleration.x = -accel.z
	msg.linear_acceleration.y = -accel.x
	msg.linear_acceleration.z = accel.y
	
	# Angular Velocity swizzle
	msg.angular_velocity.x = -ang_vel.z
	msg.angular_velocity.y = -ang_vel.x
	msg.angular_velocity.z = ang_vel.y
	
	# Orientation swizzle (Matches your C++ RosNode3D basis change)
	var basis_g_to_r = Basis(Vector3(0,0,-1), Vector3(-1,0,0), Vector3(0,1,0))
	var ros_quat = (basis_g_to_r * Basis(rot) * basis_g_to_r.inverse()).get_rotation_quaternion()
	
	msg.orientation.x = ros_quat.x
	msg.orientation.y = ros_quat.y
	msg.orientation.z = ros_quat.z
	msg.orientation.w = ros_quat.w
	
	_imu_pub.publish(msg)
