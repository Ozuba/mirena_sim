extends RosTfBroadcaster3D
class_name RosImagePublisher

# --- Configuration ---
@export var topic_name: String = "camera/"
@export var resolution: Vector2i = Vector2i(640, 480)
# frame_id and publish_rate are inherited from RosNode3D

# --- Internal Variables ---
var _node: RosNode
var _camera_pub: RosPublisher
var _camera_info_pub : RosPublisher
var _camera_info : RosSensorMsgsCameraInfo
var rd: RenderingDevice
var is_requesting: bool = false

func _ready() -> void:
	# 1. Guard against Editor execution

	# 2. Initialize ROS Node and Publisher
	_node = RosNode.new()
	_node.init("camera_node")
	_camera_pub = _node.create_publisher(topic_name + "image_raw", "sensor_msgs/msg/Image")
	_camera_info_pub = _node.create_publisher(topic_name + "camera_info", "sensor_msgs/msg/CameraInfo")

	# Init camera info and cache it
	_camera_info = fill_camera_info($CameraViewport/Camera3D)

	# 3. Get the Main Rendering Device (Required for Async)
	rd = RenderingServer.get_rendering_device()
	if not rd:
		push_error("Async publishing requires Forward+ or Mobile renderer!")
		return

	# 4. Configure the Timer (Assuming it's a child node named 'CameraTimer')
	var timer = $CameraTimer
	timer.wait_time = 1.0 / publish_rate
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	
	print("[ROS] Image Publisher started: ", topic_name)

func _on_timer_timeout() -> void:
	if is_requesting or not _camera_pub:
		return
	
	var viewport = $CameraViewport
	var tex = viewport.get_texture()
	
	# --- THE FIX FOR "tex is null" ---
	# We must convert the High-Level RID to a Low-Level RenderingDevice RID
	var rd_tex_rid = RenderingServer.texture_get_rd_texture(tex.get_rid())
	
	if not rd_tex_rid.is_valid():
		return

	is_requesting = true
	# Request data from GPU asynchronously (No frame stutter!)
	rd.texture_get_data_async(rd_tex_rid, 0, _on_data_received)

func _on_data_received(data: PackedByteArray) -> void:
	is_requesting = false
	
	if data.is_empty():
		return

	# 5. Process the raw byte array
	# Viewport data comes back as RGBA8 (4 bytes per pixel)
	var img = Image.create_from_data(resolution.x, resolution.y, false, Image.FORMAT_RGBA8, data)
	
	# Convert to ROS standard RGB8 (Strips alpha channel)
	img.convert(Image.FORMAT_RGB8)

	# 6. Build and Publish
	var msg = RosSensorMsgsImage.new()
	msg.header.stamp = _node.now()
	msg.header.frame_id = frame_id
	
	msg.height = resolution.y
	msg.width = resolution.x
	msg.encoding = "rgb8"
	msg.is_bigendian = false
	msg.step = resolution.x * 3
	msg.data = img.get_data() # GDExtension handles the byte copy

	_camera_pub.publish(msg)
	_camera_info_pub.publish(_camera_info)
	
func fill_camera_info(camera: Camera3D):
	var camera_info = RosSensorMsgsCameraInfo.new()
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
