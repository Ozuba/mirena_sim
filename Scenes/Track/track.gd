extends Node3D
class_name Track

# Properties
@export var track_width : float = 3.0
@export var track_spacing : float = 4.0

# Now stores Curve3D directly
var track_curve : Curve3D = Curve3D.new() 
@onready var track_path : Path3D = $TrackPath

# Internal Refs
static var _gate_scene = preload("res://Scenes/Track/Gate/gate.tscn")
static var _cone_scene = preload("res://Scenes/Track/Cone/cone.tscn")

signal track_loaded
var origin : Dictionary = {
	"x": 0.0,
	"y": 0.0,
	"psi": 0.0
}

func _ready() -> void:
	Sim.track = self

## Pass a Curve3D here instead of Curve2D
func create_track(path: Curve3D):
	clear_track()
	track_curve = path
	track_path.curve = path # No conversion needed anymore
	
	var length = path.get_baked_length()
	var num_gates = int(length / track_spacing)

	for i in range(0, num_gates):
		var d = (i * track_spacing)
		
		var gate = _gate_scene.instantiate() as Gate
		$Gates.add_child(gate) 
		
		gate.gate_width = track_width
		gate.gate_type = Gate.GateType.EVENT if (i == 0) else Gate.GateType.STANDARD
		
		# 1. Position of the current gate (Directly from Curve3D)
		var current_pos = path.sample_baked(d)
		
		# 2. Position of the NEXT gate for orientation
		# If the curve is closed, we wrap around using fmod
		var next_d = d + track_spacing
		if path.closed:
			next_d = fmod(next_d, length)
		else:
			next_d = min(next_d, length)
			
		var next_pos = path.sample_baked(next_d)
		
		# 3. Apply Transform
		gate.global_position = current_pos
		
		# Handle orientation
		if current_pos.distance_to(next_pos) > 0.1:
			gate.look_at(next_pos, Vector3.UP)
			gate.rotate_object_local(Vector3.UP, PI)
		else:
			# Fallback: Sample the up vector/tangent provided by the curve
			var transform = path.sample_baked_with_rotation(d)
			gate.global_transform = transform
		# Dirty change to a track start position + signal
		origin = get_gate_positions()[-1]
		track_loaded.emit()
			
func load_track(path : String):
	clear_track()
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	var data = json.data
	# Load Cones
	if data.has("cones"):
		for cone_data in data["cones"]:
			var cone = _cone_scene.instantiate() as Cone
			cone.position = Vector3(cone_data["x"], 0.0, cone_data["y"])
			match cone_data["type"]:
				"cone_blue":
					cone.type = Cone.ConeColor.BLUE
				"cone_yellow":
					cone.type = Cone.ConeColor.YELLOW
				"cone_orange":
					cone.type = Cone.ConeColor.ORANGE
				"cone_big_orange":
					cone.type = Cone.ConeColor.BIG_ORANGE
			cone.add_to_group("Cones") # Vital para el Lidar
			cone.rotation.y = randf_range(0,PI/2)
			$Gates.add_child(cone)
	# Set car to start position
	origin = data["setup"]["car_start_pose"]
	track_loaded.emit()
			
			
func clear_track():
	for n in $Gates.get_children(): n.queue_free()

func get_gate_positions() -> Array[Dictionary]:
	var data: Array[Dictionary] = []
	
	for gate in $Gates.get_children():
		if gate is Node3D:
			# Standard 3D coordinates
			data.append({
				"x": gate.global_position.x,
				"y": gate.global_position.z, # Vertical height
				"psi": gate.global_rotation.y # Yaw
			})
			
	return data
