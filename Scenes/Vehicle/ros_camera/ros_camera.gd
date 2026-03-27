extends Node3D # Converted from RosTfBroadcaster3D
class_name RosImagePublisher

# --- Configuration ---
@export var resolution: Vector2i = Vector2i(640, 480)
@export var publish_rate: float = 15.0
@export var frame_id: String = "~camera"
@export var parent_frame_id: String = "~base_link"
@export var optical_frame_id: String = "~camera_optical"

# --- ROS Components ---
var _node: RosNode
var _camera_pub: RosPublisher
var _camera_info_pub: RosPublisher
var _tf_broadcaster: RosTfBroadcaster

# --- Internal Variables ---
var _camera_info: RosSensorMsgsCameraInfo
var _msg: RosSensorMsgsImage
var rd: RenderingDevice

var is_initialized: bool = false
var is_requesting: bool = false
var _current_stamp: RosMsg
var _time_since_last_publish: float = 0.0


# Helpers
var optical_tf = Transform3D(Basis(Vector3(0, -1, 0), Vector3(0, 0, 1), Vector3(-1, 0, 0)).orthonormalized(), Vector3.ZERO)
func init(ros_ns: String) -> void:
	# 1. Initialize ROS Node in car namespace
	_node = RosNode.new()
	_node.init(name.to_snake_case(), ros_ns)
	
	# 2. Setup Factory-Created Components
	_camera_pub = _node.create_publisher("~/image_raw", "sensor_msgs/msg/Image")
	_camera_info_pub = _node.create_publisher("~/camera_info", "sensor_msgs/msg/CameraInfo")
	_tf_broadcaster = _node.create_tf_broadcaster()

	# 3. Setup Hardware Rendering
	rd = RenderingServer.get_rendering_device()
	var viewport = $CameraViewport
	viewport.size = resolution
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

	# 4. Prepare Static Messages & Resolution
	_camera_info = fill_camera_info($CameraViewport/Camera3D)
	_prepare_msg_template()
	
	## Publish transforms 
	# Uses C++ logic to swizzle Godot (Y-Up) to ROS (Z-Up)
	_tf_broadcaster.send_transform(transform, frame_id, parent_frame_id, true)
	# Tf of optical frame
	_tf_broadcaster.send_transform(optical_tf, optical_frame_id, frame_id, true)
	is_initialized = true

func _process(delta: float) -> void:
	if not is_initialized: return


	# --- PERIODIC IMAGE CAPTURE ---
	if not is_requesting:
		_time_since_last_publish += delta
		if _time_since_last_publish >= 1.0 / publish_rate:
			_time_since_last_publish = 0
			_capture_frame()

func _capture_frame() -> void:
	is_requesting = true
	_current_stamp = _node.now()
	$CameraViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	# Named signal connection (No lambda)
	if not RenderingServer.frame_post_draw.is_connected(_on_frame_drawn):
		RenderingServer.frame_post_draw.connect(_on_frame_drawn, CONNECT_ONE_SHOT)

func _on_frame_drawn() -> void:
	var tex = $CameraViewport.get_texture()
	var rid = RenderingServer.texture_get_rd_texture(tex.get_rid())
	if rid.is_valid():
		rd.texture_get_data_async(rid, 0, _on_data_received)
	else:
		is_requesting = false

func _on_data_received(data: PackedByteArray) -> void:
	if not data.is_empty():
		var optical_frame_name = _node.resolve_frame(optical_frame_id)
		# Update Image Msg
		_msg.header.stamp = _current_stamp
		_msg.header.frame_id = optical_frame_name
		_msg.data = data
		
		# Update Info Msg
		_camera_info.header.stamp = _current_stamp
		_camera_info.header.frame_id = optical_frame_name
		
		# Send Messages
		_camera_pub.publish(_msg)
		_camera_info_pub.publish(_camera_info)
		
	is_requesting = false



func _prepare_msg_template() -> void:
	_msg = RosSensorMsgsImage.new()
	_msg.height = resolution.y
	_msg.width = resolution.x
	_msg.encoding = "rgba8"
	_msg.step = resolution.x * 4
	
func fill_camera_info(camera: Camera3D):
	var camera_info = RosSensorMsgsCameraInfo.new()
	camera_info.header.frame_id = optical_frame_id
	var viewport_size = camera.get_viewport().get_visible_rect().size
	
	# 1. Basic Dimensions
	camera_info.width = int(viewport_size.x)
	camera_info.height = int(viewport_size.y)
	
	# 2. Distortion Model
	# Simulation cameras are perfectly linear, so we use the standard "plumb_bob" 
	# model with zeroed coefficients.
	camera_info.distortion_model = "plumb_bob"
	camera_info.d = PackedFloat64Array([0.0, 0.0, 0.0, 0.0, 0.0])
	
	# 3. Compute Intrinsics (K)
	# Focal length in pixels is derived from the vertical FOV.
	var fovy_rad = deg_to_rad(camera.fov)
	var fy = viewport_size.y / (2.0 * tan(fovy_rad / 2.0))
	var fx = fy # Assuming square pixels
	
	# Principal point is the center of the image.
	var cx = viewport_size.x / 2.0
	var cy = viewport_size.y / 2.0
	
	# K Matrix (3x3 row-major)
	camera_info.k = PackedFloat64Array([
		fx,  0.0, cx,
		0.0, fy,  cy,
		0.0, 0.0, 1.0
	])
	
	# 4. Rectification (R)
	# Identity matrix as the image is already rectified in simulation.
	camera_info.r = PackedFloat64Array([
		1.0, 0.0, 0.0,
		0.0, 1.0, 0.0,
		0.0, 0.0, 1.0
	])
	
	# 5. Projection (P)
	# For monocular, P is K with an added zero-column for translation.
	camera_info.p = PackedFloat64Array([
		fx,  0.0, cx,  0.0,
		0.0, fy,  cy,  0.0,
		0.0, 0.0, 1.0, 0.0
	])
	
	# 6. Operational Parameters
	camera_info.binning_x = 0
	camera_info.binning_y = 0
	# Default ROI (zeros) indicates the full resolution is used.
	return camera_info
