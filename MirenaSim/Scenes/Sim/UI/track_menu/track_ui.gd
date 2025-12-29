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

func _input(event):
	if event.is_action_pressed("track_menu"):
		visible = !visible

func _ready():
	# Connect Buttons
	$HBoxContainer/VBoxContainer/RegenNoise.pressed.connect(_on_generate_new_map)
	$HBoxContainer/VBoxContainer/Next.pressed.connect(_on_next_pressed)
	$HBoxContainer/VBoxContainer/Prev.pressed.connect(_on_prev_pressed)
	$HBoxContainer/VBoxContainer/GenerateTrack.pressed.connect(_on_generate_curve_pressed)
	
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.005                      
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE #
		
	# Initial generation
	_on_generate_new_map()

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

	# Extract and Filter
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
	
	var smoothed = Geometry2D.offset_polygon(raw_track, 3.0, Geometry2D.JOIN_ROUND)
	if not smoothed.is_empty():
		smoothed = Geometry2D.offset_polygon(smoothed[0], -1.0, Geometry2D.JOIN_ROUND)
	
	if not smoothed.is_empty():
		track_line.points = smoothed[0]
		track_line.closed = true

func _on_generate_curve_pressed():
	if track_line.points.is_empty():
		print("No track selected!")
		return
		
	# 1. Calculate the Bounding Box of the points
	var min_pos = track_line.points[0]
	var max_pos = track_line.points[0]
	for p in track_line.points:
		min_pos.x = min(min_pos.x, p.x)
		min_pos.y = min(min_pos.y, p.y)
		max_pos.x = max(max_pos.x, p.x)
		max_pos.y = max(max_pos.y, p.y)
	
	var size = max_pos - min_pos
	var center = min_pos + (size / 2.0)
	
	# 2. Determine Scale Factor
	# We want the largest side to be 100.0 units
	var max_dim = max(size.x, size.y)
	var scale_factor = 1.0
	if max_dim > 0:
		scale_factor = 100.0 / max_dim

	var curve = Curve2D.new()
	
	# 3. Apply Centering and Scaling to each point
	for p in track_line.points:
		var normalized_p = (p - center) * scale_factor
		curve.add_point(normalized_p)
		
	# Close the curve mathematically with the normalized first point
	var first_p_normalized = (track_line.points[0] - center) * scale_factor
	curve.add_point(first_p_normalized) 

	print("Curve2D Normalized. Size: ", size, " Scale: ", scale_factor)
	Sim.track.create_track(curve)

	visible = false
