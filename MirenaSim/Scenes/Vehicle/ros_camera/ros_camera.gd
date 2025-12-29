extends RosNode3D
class_name RosImagePublisher

# --- Configuration ---
@export var topic_name: String = "camera/image_raw"
@export var resolution: Vector2i = Vector2i(640, 480)
# frame_id and publish_rate are inherited from RosNode3D

# --- Internal Variables ---
var _node: RosNode
var _camera_pub: RosPublisher
var rd: RenderingDevice
var is_requesting: bool = false

func _ready() -> void:
	# 1. Guard against Editor execution
	if Engine.is_editor_hint() or not rclgd.ok():
		return

	# 2. Initialize ROS Node and Publisher
	_node = RosNode.new()
	_node.init("camera_node")
	_camera_pub = _node.create_publisher(topic_name, "sensor_msgs/msg/Image")

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
