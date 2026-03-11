extends RosTfBroadcaster3D

# --- Configuration ---
const TEXTURE_SIZE = Vector2i(600, 125)
@export var lidar_topic: String = "/sim/lidar"
@export var noise_std_dev : float = 0.005
@export var lidar_rate = 10.0 # Target rate in Hz
@export var train_split_ratio : float = 0.8 

# --- Internal ROS & RD Variables ---
var _node: RosNode
var _lidar_pub: RosPublisher
var _rd: RenderingDevice
var _texture_rid: RID
var _cached_msg: RosSensorMsgsPointCloud2

# -- Dataset Builder --
const DATASET_DIR = "user://dataset/"
var sample_index : int = 0

# --- State & Sync ---
var _is_waiting_for_gpu: bool = false
var _timestamp_queue: Array = []
var _time_since_last_scan: float = 0.0
var _pending_snapshot: bool = false

func _ready() -> void:
	# 1. Initialize ROS
	_node = RosNode.new()
	_node.init("GPULidarNode")
	_lidar_pub = _node.create_publisher(lidar_topic, "sensor_msgs/msg/PointCloud2")
	
	_initialize_sample_index() 

	# 2. Setup Rendering Device
	_rd = RenderingServer.get_rendering_device()
	if not _rd:
		push_error("GPULidar: RenderingDevice not found. Use Forward+ renderer.")
		return

	# 3. Create the RD Texture
	var fmt : RDTextureFormat = RDTextureFormat.new()
	fmt.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	fmt.width = TEXTURE_SIZE.x
	fmt.height = TEXTURE_SIZE.y
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | \
					 RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	_texture_rid = _rd.texture_create(fmt, RDTextureView.new())
	
	# 4. Inject into the CompositorEffect
	var viewport = $LidarViewport
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED # Manual trigger only
	
	var camera = $LidarViewport/LidarCamera
	if camera.compositor and camera.compositor.compositor_effects.size() > 0:
		var effect = camera.compositor.compositor_effects[0]
		effect.target_tex = _texture_rid
		effect.texture_size = TEXTURE_SIZE
		effect.std_dev = noise_std_dev
	
	_prepare_msg_template()

func _process(delta: float) -> void:
	# Handle automated periodic scanning (replaces the Timer)
	_time_since_last_scan += delta
	if _time_since_last_scan >= (1.0 / lidar_rate):
		_time_since_last_scan = 0.0
		trigger_lidar_scan()

# --- Core Precision Logic ---

func trigger_lidar_scan() -> void:
	if _is_waiting_for_gpu or not _texture_rid.is_valid():
		return
		
	_is_waiting_for_gpu = true
	
	# 1. Capture the exact "Simulation Now" time
	_timestamp_queue.push_back(_node.now())
	
	# 2. Request a single frame update from the Lidar Viewport
	$LidarViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	# 3. Connect to the signal that fires when GPU finishes rendering the frame
	if not RenderingServer.frame_post_draw.is_connected(_on_frame_drawn):
		RenderingServer.frame_post_draw.connect(_on_frame_drawn, CONNECT_ONE_SHOT)

func _on_frame_drawn() -> void:
	# 4. Start the async copy from GPU to CPU
	var err = _rd.texture_get_data_async(_texture_rid, 0, _on_texture_data_ready)
	if err != OK:
		_is_waiting_for_gpu = false
		_timestamp_queue.pop_front()
		push_error("GPULidar: Async request failed: ", err)

func _on_texture_data_ready(raw_bytes: PackedByteArray) -> void:
	_is_waiting_for_gpu = false
	
	if raw_bytes.is_empty() or _timestamp_queue.is_empty():
		return 
	
	# 5. Populate message with Synchronized Timestamp
	_cached_msg.header.stamp = _timestamp_queue.pop_front()
	_cached_msg.width = raw_bytes.size() / 16
	_cached_msg.row_step = raw_bytes.size()
	_cached_msg.data = raw_bytes 
	
	_lidar_pub.publish(_cached_msg)
	
	# 6. If a snapshot was requested, save this specific synchronized buffer
	if _pending_snapshot:
		_perform_save()
		_pending_snapshot = false

# --- ROS Template & Helpers ---

func _prepare_msg_template():
	_cached_msg = RosSensorMsgsPointCloud2.new()
	_cached_msg.height = 1
	_cached_msg.is_dense = true
	_cached_msg.point_step = 16 
	_cached_msg.header.frame_id = frame_id
	_cached_msg.fields = [
		_create_field("x", 0, 7), 
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

# --- Dataset Generation ---

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("point_pillar_snapshot"):
		# We don't save immediately. We trigger a scan and wait for the GPU callback.
		_pending_snapshot = true
		trigger_lidar_scan()

func _perform_save():
	var file_id = "%06d" % sample_index
	var f_bin = FileAccess.open(DATASET_DIR + "points/" + file_id + ".bin", FileAccess.WRITE)
	if f_bin:
		f_bin.store_buffer(_cached_msg.data)
		
	save_kitti_labels(file_id)
	save_dummy_calib(file_id)
	_assign_to_split(file_id)
	
	sample_index += 1
	print("GPULidar: Precision Snapshot saved as index ", sample_index - 1)

func _initialize_sample_index():
	DirAccess.make_dir_recursive_absolute(DATASET_DIR + "points")
	DirAccess.make_dir_recursive_absolute(DATASET_DIR + "labels")
	DirAccess.make_dir_recursive_absolute(DATASET_DIR + "calib")
	DirAccess.make_dir_recursive_absolute(DATASET_DIR + "ImageSets")

	var files = DirAccess.get_files_at(DATASET_DIR + "points")
	sample_index = files.size()
	
	if sample_index == 0:
		var dir = DirAccess.open(DATASET_DIR + "ImageSets")
		if dir:
			dir.remove("train.txt")
			dir.remove("val.txt")
			dir.remove("trainval.txt")

func save_kitti_labels(file_id: String):
	var label_path = DATASET_DIR + "labels/" + file_id + ".txt"
	var f = FileAccess.open(label_path, FileAccess.WRITE)
	var cones = get_tree().get_nodes_in_group("Cones")
	
	for cone in cones:
		var global_cone_pos = cone.global_position
		if not $LidarViewport/LidarCamera.is_position_in_frustum(global_cone_pos):
			continue
		
		var local_pos = global_transform.affine_inverse() * global_cone_pos
		if local_pos.length() > 20.0:
			continue
			
		var kitti_x = local_pos.z
		var kitti_y = -local_pos.x # Standard KITTI coordinate swap
		var kitti_z = local_pos.y
		
		var line = "%s 0 0 0 0 0 0 0 0.325 0.2 0.2 %.4f %.4f %.4f 0" % \
			[cone.get_type_as_string(), kitti_x, kitti_y, kitti_z]
		f.store_line(line)
	f.close()

func _assign_to_split(id: String):
	var filename = "train.txt" if randf() < train_split_ratio else "val.txt"
	_append_to_file(DATASET_DIR + "ImageSets/" + filename, id)
	_append_to_file(DATASET_DIR + "ImageSets/trainval.txt", id)

func _append_to_file(path: String, line_content: String):
	var f = FileAccess.open(path, FileAccess.READ_WRITE) if FileAccess.file_exists(path) \
			else FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.seek_end()
		f.store_line(line_content)
		f.close()

func save_dummy_calib(file_id: String):
	var path = DATASET_DIR + "calib/" + file_id + ".txt"
	var f = FileAccess.open(path, FileAccess.WRITE)
	f.store_line("P0: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.store_line("P1: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.store_line("P2: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.store_line("P3: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.store_line("R0_rect: 1 0 0 0 1 0 0 0 1")
	f.store_line("Tr_velo_to_cam: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.store_line("Tr_imu_to_velo: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.close()

func _exit_tree():
	if _texture_rid.is_valid():
		_rd.free_rid(_texture_rid)
