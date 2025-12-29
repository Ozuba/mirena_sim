extends Node3D
class_name Track
# Properties
@export var track_width : float = 3.0
@export var track_spacing : float = 4.0

var track_curve : Curve2D
@onready var track_path : Path3D = $TrackPath

# Internal Refs
static var _gate_scene = preload("res://Scenes/Track/Gate/gate.tscn")


func _ready() -> void:
	Sim.track = self
	
func _process(delta: float) -> void:
	pass

func create_track(path: Curve2D):
	_clear_track()
	track_curve = path
	track_path.curve = get_track_curve3d(path)
	var length = path.get_baked_length()
	var num_gates = int(length / track_spacing)

	for i in range(0, num_gates):
		var d = (i * track_spacing)
		
		var gate = _gate_scene.instantiate() as Gate
		# Add to tree BEFORE setting global_transform to ensure coordinates work
		$Gates.add_child(gate) 
		
		gate.gate_width = track_width
		gate.gate_type = Gate.GateType.EVENT if (i == 0) else Gate.GateType.STANDARD
		
		# 1. Position of the current gate
		var current_pos_2d = path.sample_baked(d)
		var current_pos_3d = Vector3(current_pos_2d.x, 0, current_pos_2d.y)
		
		# 2. Position of the NEXT gate (target)
		# We clamp the distance to the path length so the last gate doesn't look at "nothing"
		var next_d = min(d + track_spacing, length)
		var next_pos_2d = path.sample_baked(next_d)
		var next_pos_3d = Vector3(next_pos_2d.x, 0, next_pos_2d.y)
		
		# 3. Apply Transform
		gate.global_position = current_pos_3d
		
		# Only look_at if we aren't at the exact same spot (prevents errors on last gate)
		if current_pos_3d.distance_to(next_pos_3d) > 0.1:
			gate.look_at(next_pos_3d, Vector3.UP)
		else:
			# Fallback for the very last gate: use the previous tangent
			var prev_t = path.sample_baked_with_rotation(d)
			gate.look_at(gate.global_position + Vector3(prev_t.x.x, 0, prev_t.x.y), Vector3.UP)
		

func _clear_track():
	for n in $Gates.get_children(): n.queue_free()
	
## Public Methods
func get_track_curve3d(curve : Curve2D) -> Curve3D:
	var curve_3d = Curve3D.new()
	var count = curve.point_count
	
	# Iterate from the last point to the first
	for i in range(count - 1, -1, -1):
		var p2 = curve.get_point_position(i)
		
		# SWAP: The 2D 'in' handle becomes the 3D 'out' handle
		# and vice versa to maintain the slope direction.
		var in2 = curve.get_point_out(i) 
		var out2 = curve.get_point_in(i)
		
		var pos3 = Vector3(p2.x, 0, p2.y)
		var in3 = Vector3(in2.x, 0, in2.y)
		var out3 = Vector3(out2.x, 0, out2.y)
		
		curve_3d.add_point(pos3, in3, out3)
		
	return curve_3d
