extends Node3D
class_name RosLidarPublisher

# --- Configuration ---
const TEXTURE_SIZE = Vector2i(600, 125)
@export var lidar_rate: float = 10.0
@export var frame_id: String = "~/lidar"
@export var parent_frame_id: String = "~/base_link"

@export var noise_std_dev : float = 0.005

# --- ROS Components ---
var _node: RosNode
var _lidar_pub: RosPublisher
var _tf_broadcaster: RosTfBroadcaster

# --- Rendering Device Variables ---
var _rd: RenderingDevice
var _texture_rid: RID
var _cached_msg: RosSensorMsgsPointCloud2

# --- State & Sync ---
var is_initialized: bool = false
var _is_waiting_for_gpu: bool = false
var _current_stamp: RosMsg
var _time_since_last_scan: float = 0.0



func init(ros_ns: String) -> void:
	_node = RosNode.new()
	_node.init(name.to_snake_case(), ros_ns)
	
	_lidar_pub = _node.create_publisher("~/cloud", "sensor_msgs/msg/PointCloud2")
	_tf_broadcaster = _node.create_tf_broadcaster()
	
	_rd = RenderingServer.get_rendering_device()
	var fmt : RDTextureFormat = RDTextureFormat.new()
	fmt.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	fmt.width = TEXTURE_SIZE.x
	fmt.height = TEXTURE_SIZE.y
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	_texture_rid = _rd.texture_create(fmt, RDTextureView.new())
	
	$LidarViewport.size = TEXTURE_SIZE
	$LidarViewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	var camera = $LidarViewport/LidarCamera
	if camera.compositor and camera.compositor.compositor_effects.size() > 0:
		var effect = camera.compositor.compositor_effects[0]
		effect.target_tex = _texture_rid
		effect.texture_size = TEXTURE_SIZE
		effect.std_dev = noise_std_dev
	
	_prepare_msg_template()
	is_initialized = true

func _process(delta: float) -> void:
	if not is_initialized: return

	# Broadcast TF 
	_tf_broadcaster.send_transform(transform, frame_id, parent_frame_id, true)


	_time_since_last_scan += delta
	if _time_since_last_scan >= (1.0 / lidar_rate):
		_time_since_last_scan = 0.0
		trigger_lidar_scan()

func trigger_lidar_scan() -> void:
	if _is_waiting_for_gpu or not _texture_rid.is_valid():
		return
		
	_is_waiting_for_gpu = true
	_current_stamp = _node.now()
	
	$LidarViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	
	if not RenderingServer.frame_post_draw.is_connected(_on_frame_drawn):
		RenderingServer.frame_post_draw.connect(_on_frame_drawn, CONNECT_ONE_SHOT)

func _on_frame_drawn() -> void:
	_rd.texture_get_data_async(_texture_rid, 0, _on_texture_data_ready)

func _on_texture_data_ready(raw_bytes: PackedByteArray) -> void:
	if not raw_bytes.is_empty():
		_cached_msg.header.stamp = _current_stamp
		_cached_msg.header.frame_id = _node.get_namespace().trim_prefix("/").path_join(frame_id.trim_prefix("~/"))
		
		_cached_msg.width = raw_bytes.size() / 16
		_cached_msg.row_step = raw_bytes.size()
		_cached_msg.data = raw_bytes 
		
		_lidar_pub.publish(_cached_msg)
	
	# Release lock after publishing is handled or failed
	_is_waiting_for_gpu = false

func _prepare_msg_template():
	_cached_msg = RosSensorMsgsPointCloud2.new()
	_cached_msg.height = 1
	_cached_msg.is_dense = true
	_cached_msg.point_step = 16 
	_cached_msg.fields = [
		_create_field("x", 0), 
		_create_field("y", 4),
		_create_field("z", 8),
		_create_field("intensity", 12)
	]

func _create_field(fname: String, offset: int) -> RosSensorMsgsPointField:
	var f = RosSensorMsgsPointField.new()
	f.name = fname
	f.offset = offset
	f.datatype = 7 # Float32
	f.count = 1
	return f

func _exit_tree():
	if _texture_rid.is_valid():
		_rd.free_rid(_texture_rid)
