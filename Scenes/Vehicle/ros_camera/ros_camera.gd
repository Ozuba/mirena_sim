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
var _time_since_last_publish: float = 0.0
var _target_interval = 1.0 / publish_rate
# Pre-allocate message to avoid GC pressure
var _msg: RosSensorMsgsImage

func _ready() -> void:
	# 1. Initialize ROS Node and Publisher
	_node = RosNode.new()
	_node.init("camera_node")
	_camera_pub = _node.create_publisher(topic_name + "/image_raw", "sensor_msgs/msg/Image")
	_camera_info_pub = _node.create_publisher(topic_name + "/camera_info", "sensor_msgs/msg/CameraInfo")

	# 2. Setup Viewport for manual triggering
	var viewport = $CameraViewport
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	viewport.size = resolution # Ensure viewport matches intended res
	
	# Init camera info and cache it
	_camera_info = fill_camera_info($CameraViewport/Camera3D)
	
	# Pre-configure message fields that don't change
	_msg = RosSensorMsgsImage.new()
	_msg.height = resolution.y
	_msg.width = resolution.x
	_msg.encoding = "rgba8" # Using RGBA8 to avoid CPU conversion costs
	_msg.is_bigendian = false
	_msg.step = resolution.x * 4 # 4 bytes for RGBA
	_msg.header.frame_id = frame_id

	# 3. Get the Main Rendering Device
	rd = RenderingServer.get_rendering_device()
	if not rd:
		push_error("[ROS] Async publishing requires Forward+ or Mobile renderer!")

func _process(_delta: float) -> void:
	# Most elegant trigger: request a frame as soon as the last one is done
	_time_since_last_publish += _delta
	if _time_since_last_publish >= _target_interval:
		_time_since_last_publish = 0
		is_requesting = true
		$CameraViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		# Log the timestamp before requesting
		_msg.header.stamp = _node.now()
		# We wait for the frame to be drawn before grabbing the RID
		RenderingServer.frame_post_draw.connect(_on_frame_drawn, CONNECT_ONE_SHOT)
		
func _on_frame_drawn():
	# This runs as soon as the RenderingServer finishes the frame
	var tex = $CameraViewport.get_texture()
	var rd_tex_rid = RenderingServer.texture_get_rd_texture(tex.get_rid())
	
	if rd_tex_rid.is_valid():
		# 4. Request the data. This is fully asynchronous.
		# No waiting here; _on_data_received is called when bytes are ready.
		rd.texture_get_data_async(rd_tex_rid, 0, _on_data_received)
	else:
		# Cleanup if the RID was invalid
		is_requesting = false


func _on_data_received(data: PackedByteArray) -> void:
	# This callback is already on the Main Thread in Godot 4
	if data.is_empty():
		is_requesting = false
		return

	# 4. Direct Publish (No Image.convert call)
	_msg.data = data # PackedByteArray is passed by reference/minimal copy
	
	_camera_pub.publish(_msg)
	_camera_info_pub.publish(_camera_info)
	
	is_requesting = false
	
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
