extends RosNode3D

# --- Configuration ---
const TEXTURE_SIZE = Vector2i(600, 125)
@export var lidar_topic: String = "/sim/LIDAR"
@export var noise_std_dev : float = 0.005

@export var train_split_ratio : float = 0.8 # 80% Train, 20% Val
# --- Internal ROS & RD Variables ---
var _node: RosNode
var _lidar_pub: RosPublisher
var _rd: RenderingDevice
var _texture_rid: RID
var _cached_msg: RosSensorMsgsPointCloud2

# -- Dataset Builder --
const DATASET_DIR = "user://dataset/"
var sample_index : int = 0
# --- State ---
var is_sampling: bool = false
@export var lidar_rate = 10.0
func _ready() -> void:
	_node = RosNode.new()
	_node.init("GPULidarNode")
	_lidar_pub = _node.create_publisher(lidar_topic, "sensor_msgs/msg/PointCloud2")
	# Init dataset
	_initialize_sample_index() 
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
		effect.std_dev = noise_std_dev
	
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
	_cached_msg.header.stamp = _node.now() 
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
	
	_lidar_pub.publish(_cached_msg)

# Memory Cleanup
func _exit_tree():
	if _texture_rid.is_valid():
		_rd.free_rid(_texture_rid)
		

## Dataset Generation
func _initialize_sample_index():
	# 1. Crear carpetas (Incluyendo la nueva ImageSets)
	DirAccess.make_dir_recursive_absolute(DATASET_DIR + "points")
	DirAccess.make_dir_recursive_absolute(DATASET_DIR + "labels")
	DirAccess.make_dir_recursive_absolute(DATASET_DIR + "calib")
	DirAccess.make_dir_recursive_absolute(DATASET_DIR + "ImageSets") # <--- NUEVO

	# 2. Calcular índice
	var files = DirAccess.get_files_at(DATASET_DIR + "points")
	sample_index = files.size()
	
	# LIMPIEZA DE SEGURIDAD:
	# Si estamos empezando desde 0, borramos los txt viejos para no mezclar datos
	if sample_index == 0:
		var dir = DirAccess.open(DATASET_DIR + "ImageSets")
		if dir:
			dir.remove("train.txt")
			dir.remove("val.txt")
			dir.remove("trainval.txt")
	
	print("GPULidar: Dataset initialized. Next frame: ", sample_index)
		
func save_snapshot():
	var file_id = "%06d" % sample_index
	
	# 1. Guardar Datos Binarios y Etiquetas (Tu código existente)
	var f_bin = FileAccess.open(DATASET_DIR + "points/" + file_id + ".bin", FileAccess.WRITE)
	if f_bin:
		f_bin.store_buffer(_cached_msg.data)
		
	save_kitti_labels(file_id)
	save_dummy_calib(file_id)
	
	# 2. ASIGNAR A TRAIN O VAL (NUEVO)
	_assign_to_split(file_id)
	
	sample_index += 1
	
func _assign_to_split(id: String):
	# Decisión aleatoria: ¿Entrenamiento o Validación?
	var is_train = randf() < train_split_ratio
	
	# Archivo destino
	var filename = "train.txt" if is_train else "val.txt"
	
	# 1. Guardar en su lista específica
	_append_to_file(DATASET_DIR + "ImageSets/" + filename, id)
	
	# 2. Guardar SIEMPRE en trainval.txt (el conjunto total)
	# Muchos modelos (como PointPillars) a veces usan este archivo para calcular estadísticas globales
	_append_to_file(DATASET_DIR + "ImageSets/trainval.txt", id)

func _append_to_file(path: String, line_content: String):
	var f: FileAccess
	
	if FileAccess.file_exists(path):
		# Si existe, abrimos en modo LECTURA_ESCRITURA
		f = FileAccess.open(path, FileAccess.READ_WRITE)
		if f:
			f.seek_end() # Saltamos al final del archivo para no sobrescribir
	else:
		# Si no existe, creamos nuevo
		f = FileAccess.open(path, FileAccess.WRITE)
	
	if f:
		f.store_line(line_content)
		f.close()

func save_kitti_labels(file_id: String):
	var label_path = DATASET_DIR + "labels/" + file_id + ".txt"
	var f = FileAccess.open(label_path, FileAccess.WRITE)
	
	var cones = get_tree().get_nodes_in_group("Cones")
	
	for cone in cones:
		var global_cone_pos = cone.global_position
		
		# 1. Frustum Check: Is the cone inside the camera's viewing pyramid?
		if not $LidarViewport/LidarCamera.is_position_in_frustum(global_cone_pos):
			continue
		
		# 2. Distance Check (Optional but recommended for Lidar limits)
		var local_pos = global_transform.affine_inverse() * global_cone_pos
		if local_pos.length() > 20.0:
			continue
			
		# 3. Coordinate Swap for KITTI (X-Forward, Y-Left, Z-Up)
		var kitti_x = local_pos.z
		var kitti_y = local_pos.x
		var kitti_z = local_pos.y
		
		# 4. Format and save
		var line = "%s 0 0 0 0 0 0 0 0.325 0.2 0.2 %f %f %f 0" % [cone.get_type_as_string(), kitti_x, kitti_y, kitti_z]
		f.store_line(line)
	
	f.close()
	
func save_dummy_calib(file_id: String):
	var path = DATASET_DIR + "calib/" + file_id + ".txt"
	var f = FileAccess.open(path, FileAccess.WRITE)
	if not f:
		return

	# P0-P3 are Camera Projection matrices (4x3)
	# R0_rect is Rectification matrix (3x3)
	# Tr_velo_to_cam is Lidar-to-Camera (3x4)
	
	# We use identity values so the coordinates stay exactly as they are in the .bin file
	f.store_line("P0: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.store_line("P1: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.store_line("P2: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.store_line("P3: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.store_line("R0_rect: 1 0 0 0 1 0 0 0 1")
	f.store_line("Tr_velo_to_cam: 1 0 0 0 0 1 0 0 0 0 1 0")
	f.store_line("Tr_imu_to_velo: 1 0 0 0 0 1 0 0 0 0 1 0")
	
	f.close()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("point_pillar_snapshot"):
		save_snapshot()
		print("GPULidar: Snapshot saved as index ", sample_index - 1)
