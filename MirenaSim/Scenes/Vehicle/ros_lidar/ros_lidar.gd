extends RosNode3D

# --- Configuration ---
const TEXTURE_SIZE = Vector2i(600, 125)

# --- Internal ROS & RD Variables ---
var _node: RosNode
var _lidar_pub: RosPublisher
var _rd: RenderingDevice
var _texture_rid: RID
var _cached_msg: RosSensorMsgsPointCloud2

# --- State ---
var is_sampling: bool = false
@export var lidar_rate = 10.0
func _ready() -> void:
	_node = RosNode.new()
	_node.init("GPULidarNode")
	_lidar_pub = _node.create_publisher("/gpu_lidar", "sensor_msgs/msg/PointCloud2")
	
	# 2. Setup Rendering Device
	_rd = RenderingServer.get_rendering_device()
	if not _rd:
		push_error("GPULidar: RenderingDevice not found. Use Forward+ or Mobile renderer.")
		return

	# 3. Create the RD Texture (R32G32B32A32_SFLOAT = 16 bytes per pixel)
	var fmt : RDTextureFormat = RDTextureFormat.new()
	fmt.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	fmt.width = TEXTURE_SIZE.x
	fmt.height = TEXTURE_SIZE.y
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | \
					 RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	_texture_rid = _rd.texture_create(fmt, RDTextureView.new())
	
	# 4. Inject into the CompositorEffect
	# We assume the first effect is your Lidar Compute Shader
	var compositor = $LidarViewport/LidarCamera.compositor
	if compositor and compositor.compositor_effects.size() > 0:
		var effect = compositor.compositor_effects[0]
		effect.target_tex = _texture_rid
		effect.texture_size = TEXTURE_SIZE
	
	# 5. Prepare ROS Message Template
	_prepare_msg_template()
	
	# 6. Setup the Publishing Timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0 / lidar_rate
	timer.timeout.connect(_on_timer_timeout)
	timer.autostart = true
	timer.start()

func _prepare_msg_template():
	_cached_msg = RosSensorMsgsPointCloud2.new()
	_cached_msg.height = 1
	_cached_msg.is_dense = true
	_cached_msg.point_step = 16 # 4 floats * 4 bytes
	_cached_msg.header.frame_id = frame_id
	
	# PointCloud2 Field Definitions Swapped coords
	_cached_msg.fields = [
		_create_field("x", 0, 7), # 7 = FLOAT32
		_create_field("y", 4, 7),
		_create_field("z", 8, 7),
		_create_field("intensity", 12, 7)
	]

func _create_field(fname: String, offset: int, datatype: int) -> RosSensorMsgsPointField:
	var f = RosSensorMsgsPointField.new()
	f.name = fname
	f.offset = offset
	f.datatype = datatype
	f.count = 1
	return f

func _on_timer_timeout():
	if is_sampling or not _texture_rid.is_valid():
		return
		
	is_sampling = true
	# Request data from GPU asynchronously.
	# The Main Rendering Device handles the submission for you.
	var err = _rd.texture_get_data_async(_texture_rid, 0, _on_texture_data_ready)
	
	if err != OK:
		is_sampling = false
		push_error("GPULidar: Async request failed with error: ", err)

func _on_texture_data_ready(raw_bytes: PackedByteArray):
	is_sampling = false
	
	if raw_bytes.is_empty():
		return 
	
	# Populate dynamic fields
	_cached_msg.width = raw_bytes.size() / 16
	_cached_msg.row_step = raw_bytes.size()
	_cached_msg.data = raw_bytes 
	_cached_msg.header.stamp = _node.now() 
	
	_lidar_pub.publish(_cached_msg)

# Memory Cleanup
func _exit_tree():
	if _texture_rid.is_valid():
		_rd.free_rid(_texture_rid)
