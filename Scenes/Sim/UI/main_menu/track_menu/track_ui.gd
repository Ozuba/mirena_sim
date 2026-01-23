extends Control

# Systems
@onready var track_line: Line2D = $HBoxContainer/TextureRect/Line2D

# Signals
signal track_generated(track : Curve2D)

# Configurable Parameters
var map_size := Vector2i(512, 512)
var threshold := 0.05
var noise: FastNoiseLite

# State Management
var all_valid_loops: Array[PackedVector2Array] = []
var current_loop_index := 0

func _ready():
	# Connect Buttons
	$HBoxContainer/VBoxContainer/RegenNoise.pressed.connect(_on_generate_new_map)
	$HBoxContainer/VBoxContainer/Next.pressed.connect(_on_next_pressed)
	$HBoxContainer/VBoxContainer/Prev.pressed.connect(_on_prev_pressed)
	$HBoxContainer/VBoxContainer/GenerateTrack.pressed.connect(_on_generate_curve_pressed)
	$HBoxContainer/VBoxContainer/OpenTrack.pressed.connect(_on_open_track_pressed)
	$HBoxContainer/VBoxContainer/ClearTrack.pressed.connect(_on_clear_track_pressed)

	
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.005              
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE 
	
	_on_generate_new_map()
	
func _on_open_track_pressed():
	$FileDialog.visible = true
	
func _on_clear_track_pressed():
	Sim.track.clear_track()

func _on_file_dialog_file_selected(path: String):    
		Sim.track.load_track(path)

func _on_generate_new_map():
	noise.seed = randi()
	update_noise_texture()
	extract_all_potential_loops()
	display_current_loop()

func update_noise_texture():
	var tex = NoiseTexture2D.new()
	tex.width = map_size.x
	tex.height = map_size.y
	tex.noise = noise
	await tex.changed
	$HBoxContainer/TextureRect.texture = tex

func extract_all_potential_loops():
	var bitmap = BitMap.new()
	bitmap.create(map_size)
	
	var center = Vector2(map_size) / 2.0
	var max_dist = center.length() * 0.8

	for x in map_size.x:
		for y in map_size.y:
			var falloff = clamp(1.0 - (Vector2(x, y).distance_to(center) / max_dist), 0.0, 1.0)
			if noise.get_noise_2d(x, y) * falloff > threshold:
				bitmap.set_bit(x, y, true)

	# Safety Border Clear
	for x in map_size.x:
		bitmap.set_bit(x, 0, false)
		bitmap.set_bit(x, map_size.y - 1, false)
	for y in map_size.y:
		bitmap.set_bit(0, y, false)
		bitmap.set_bit(map_size.x - 1, y, false)

	var polys = bitmap.opaque_to_polygons(Rect2i(0, 0, map_size.x, map_size.y))
	all_valid_loops = polys.filter(func(p): return p.size() > 30)
	current_loop_index = 0

func _on_next_pressed():
	if all_valid_loops.is_empty(): return
	current_loop_index = (current_loop_index + 1) % all_valid_loops.size()
	display_current_loop()

func _on_prev_pressed():
	if all_valid_loops.is_empty(): return
	current_loop_index = (current_loop_index - 1 + all_valid_loops.size()) % all_valid_loops.size()
	display_current_loop()

func display_current_loop():
	if all_valid_loops.is_empty():
		track_line.points = PackedVector2Array()
		return
	
	var raw_track = all_valid_loops[current_loop_index]
	
	# Initial visualization smoothing
	var smoothed = Geometry2D.offset_polygon(raw_track, 2.0, Geometry2D.JOIN_ROUND)
	if not smoothed.is_empty():
		track_line.points = smoothed[0]
		track_line.closed = true

# --- SMOOTHING LOGIC ---

func chaikin_smooth(points: PackedVector2Array, iterations: int = 2) -> PackedVector2Array:
	var output = points
	for i in range(iterations):
		var new_points = PackedVector2Array()
		for j in range(output.size()):
			var p0 = output[j]
			var p1 = output[posmod(j + 1, output.size())]
			
			# Chaikin cutting: creating new points at 25% and 75% of the segment
			new_points.append(p0.lerp(p1, 0.25))
			new_points.append(p0.lerp(p1, 0.75))
		output = new_points
	return output
	
func _on_generate_curve_pressed():
	if all_valid_loops.is_empty(): return
	
	var raw_points = all_valid_loops[current_loop_index]
	
	# 1. Chaikin Smoothing (Assuming these return Vector2, we handle conversion later)
	var smooth_points = chaikin_smooth(raw_points, 2)
	
	# 2. Geometry Simplification
	var simplified = simplify_points(smooth_points, 1.5)
	
	# 3. Normalization (Scaling/Centering)
	var min_pos = simplified[0]; var max_pos = simplified[0]
	for p in simplified:
		min_pos.x = min(min_pos.x, p.x); min_pos.y = min(min_pos.y, p.y)
		max_pos.x = max(max_pos.x, p.x); max_pos.y = max(max_pos.y, p.y)
	
	var center = min_pos + ((max_pos - min_pos) / 2.0)
	var scale_factor = 100.0 / max((max_pos - min_pos).x, (max_pos - min_pos).y)

	# --- CHANGED TO CURVE3D ---
	var curve = Curve3D.new()
	for p in simplified:
		# Convert 2D point (x, y) to 3D point (x, 0, z)
		var pos_2d = (p - center) * scale_factor
		curve.add_point(Vector3(pos_2d.x, 0, pos_2d.y))
	
	# Close loop natively (if Godot 4.4+) or by adding the first point again
	if "closed" in curve:
		curve.closed = true
	else:
		curve.add_point(curve.get_point_position(0))

	# 4. Proportional Bezier Tangents (Updated for Vector3)
	for i in range(curve.point_count):
		var p_curr = curve.get_point_position(i)
		var p_prev = curve.get_point_position(posmod(i - 1, curve.point_count))
		var p_next = curve.get_point_position(posmod(i + 1, curve.point_count))
		
		# Calculate direction in 3D space
		var dir = (p_next - p_prev).normalized()
		var safe_dist = min(p_curr.distance_to(p_prev), p_curr.distance_to(p_next)) * 0.35 
		
		# Set 3D tangents (Y remains 0 for a flat track)
		curve.set_point_in(i, -dir * safe_dist)
		curve.set_point_out(i, dir * safe_dist)

	# 5. Tessellation (Curve3D.tessellate returns a PackedVector3Array)
	var final_points = curve.tessellate(5, 2)
	var final_curve = Curve3D.new()
	
	# If the original was closed, the tessellated curve should be too
	if "closed" in final_curve:
		final_curve.closed = curve.closed

	for p in final_points:
		final_curve.add_point(p)

	# Send the Curve3D to your Track script
	Sim.track.create_track(final_curve)

# FALLBACK SIMPLIFICATION (Ramer-Douglas-Peucker Lite)
# Use this if Geometry2D.simplify_polyline gives you errors
func simplify_points(pts: PackedVector2Array, epsilon: float) -> PackedVector2Array:
	if pts.size() < 3: return pts
	
	var res = PackedVector2Array()
	res.append(pts[0])
	
	for i in range(1, pts.size() - 1):
		var prev = res[res.size() - 1]
		var curr = pts[i]
		var next = pts[i + 1]
		
		# Only keep the point if it significantly changes the direction
		if prev.distance_to(curr) > epsilon:
			res.append(curr)
			
	res.append(pts[pts.size() - 1])
	return res
