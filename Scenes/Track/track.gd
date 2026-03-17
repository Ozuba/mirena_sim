extends Node3D
class_name Track

# Properties
@export var track_width : float = 3.0
@export var track_spacing : float = 4.0

# ROS 2 Frame: X Forward (+Z), Y Left (+X), Z Up (+Y)
var track_curve : Curve3D = Curve3D.new() 
@onready var track_path : Path3D = $TrackPath



# Internal Refs
static var _gate_scene = preload("res://Scenes/Track/Gate/gate.tscn")
static var _cone_scene = preload("res://Scenes/Track/Cone/cone.tscn")

# Track Generator
var track_gen = TrackGenerator.new()
signal track_loaded

# ROS node to manage tracks
var _node: RosNode
var _track_pub : RosPublisher
var _map_pub : RosPublisher
var _map_timer : RosTimer
var _track_timer : RosTimer

# Standard ROS 2 Origin (X: Forward, Y: Left, PSI: Counter-Clockwise Yaw)
var origin : Dictionary = {
	"x": 0.0,
	"y": 0.0,
	"psi": 0.0
}

# Parameter handling
func _on_ros_parameter_changed(param_name: String, value: Variant):
	if param_name == "track":
		if value == "random":
			create_track()
		else:
			if FileAccess.file_exists(value):
				load_track(value)
		


func _ready() -> void:
	_node = RosNode.new()
	_node.init("track_manager","sim")
	# Track name parameter and callback
	_node.declare_parameter("track", "")
	_node.parameter_changed.connect(_on_ros_parameter_changed)
	# Publishers
	_track_pub = _node.create_publisher("~/track","mirena_common/msg/Track")
	_map_pub = _node.create_publisher("~/full_map","mirena_common/msg/EntityList")
	# Timers for publishers
	_map_timer = _node.create_timer(1,_publish_full_map)
	_track_timer = _node.create_timer(1,_publish_track)
	
	#Check parameter
	var value = _node.get_parameter("track")
	if value == "random":
		create_track()
	else:
		if FileAccess.file_exists(value):
			load_track(value)
	

	
# ROS publishers
func _publish_full_map():
	var msg = RosMirenaCommonEntityList.new()
	msg.header.frame_id = "map"
	msg.header.stamp = _node.now()
	msg.entities = get_tree().get_nodes_in_group("Cones").map(func(c): return _to_ent(c,true))
	_map_pub.publish(msg)


func _publish_track():
	if not Sim.track: return
	var msg = RosMirenaCommonTrack.new()
	msg.header.frame_id = "map"
	msg.header.stamp = _node.now()
	msg.is_closed = track_curve.closed
	msg.gates = get_gate_positions().map(func(gp):
		var gate = RosMirenaCommonGate.new()
		gate.x = gp.x; gate.y = gp.y; gate.psi = gp.psi
		return gate
	)
	_track_pub.publish(msg)
	
func _to_ent(cone: Node3D, global : bool = false  ) -> RosMirenaCommonEntity:
	var ent = RosMirenaCommonEntity.new()
	var pos =  cone.global_position if global else to_local(cone.global_position)
	ent.type = cone.get_type_as_string()
	
	# ROS Swizzle: Forward=Z, Left=-X, Up=Y
	ent.position.x = pos.z
	ent.position.y = pos.x
	ent.position.z = pos.y
	return ent
	
func create_track():
	clear_track()
	# Update curve and path
	track_curve = track_gen.generate()
	track_path.curve = track_curve
	
	var length = track_curve.get_baked_length()
	var num_gates = int(length / track_spacing)

	for i in range(0, num_gates):
		var d = (i * track_spacing)
		var gate = _gate_scene.instantiate() as Gate
		$Gates.add_child(gate) 
		
		gate.gate_width = track_width
		gate.gate_type = Gate.GateType.EVENT if (i == 0) else Gate.GateType.STANDARD
		
		var trans = track_curve.sample_baked_with_rotation(d, true)
		gate.global_transform = trans
		gate.rotate_object_local(Vector3.UP, PI)

	# --- Shifted Origin Logic ---
	var p0 = track_curve.get_point_position(0)
	var p1 = track_curve.get_point_position(1)
	var dir = (p1 - p0).normalized()

	# Move p0 back by 2 meters along the negative direction of the track
	var shifted_p0 = p0 - (dir * 4.0)

	origin = {
		"x": shifted_p0.z,       # ROS X (Godot +Z)
		"y": shifted_p0.x,       # ROS Y (Godot +X)
		"psi": atan2(dir.x, dir.z) # Yaw remains the same
	}
	
	track_loaded.emit()

func load_track(path : String):
	clear_track()
	var file = FileAccess.open(path, FileAccess.READ)
	if not file: return
	
	var json = JSON.new()
	json.parse(file.get_as_text())
	var data = json.data
	
	# Load Cones: ROS X -> Godot Z | ROS Y -> Godot X
	if data.has("cones"):
		for cone_data in data["cones"]:
			var cone = _cone_scene.instantiate() as Cone
			# ROS X is Z, ROS Y is X
			cone.position = Vector3(cone_data["y"], 0.0, cone_data["x"])
			
			match cone_data["type"]:
				"cone_blue": cone.type = Cone.ConeColor.BLUE
				"cone_yellow": cone.type = Cone.ConeColor.YELLOW
				"cone_orange": cone.type = Cone.ConeColor.ORANGE
				"cone_big_orange": cone.type = Cone.ConeColor.BIG_ORANGE
			
			cone.add_to_group("Cones")
			cone.rotation.y = randf_range(0, PI/2)
			$Gates.add_child(cone)

	if data.has('path'):
		track_curve.clear_points()
		for p in data['path']:
			# Mapping ROS path points back to Godot space
			track_curve.add_point(Vector3(p['y'], 0.0, p['x']))

	# Start pose directly assigned from ROS 2 input
	origin = {
		"x": data.setup.car_start_pose.x,
		"y": data.setup.car_start_pose.y,
		"psi": data.setup.car_start_pose.psi
	}
	
	track_loaded.emit()

func clear_track():
	for n in $Gates.get_children(): n.queue_free()

func get_gate_positions() -> Array[Dictionary]:
	var length = track_curve.get_baked_length()
	var num_points = int(length / track_spacing)
	var data: Array[Dictionary] = []
	
	for i in range(0, num_points):
		var d = (i * track_spacing)
		var pos = track_curve.sample_baked(d)
		
		# Get direction by looking at next point
		var next_d = fmod(d + 0.1, length)
		var next_pos = track_curve.sample_baked(next_d)
		var dir = (next_pos - pos).normalized()
		
		data.append({
			"x": pos.z,        # Godot +Z is ROS X
			"y": pos.x,        # Godot +X is ROS Y
			"psi": atan2(dir.x, dir.z) # Counter-clockwise yaw from X (+Z)
		})
	return data
