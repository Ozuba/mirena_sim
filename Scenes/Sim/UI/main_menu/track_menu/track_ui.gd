extends Control

@onready var track_line: Line2D = $HBoxContainer/TextureRect/Line2D
@onready var texture_rect: TextureRect = $HBoxContainer/TextureRect

var generator: TrackGenerator
var current_loop_index := 0

func _ready():
	# 1. Initialize the Generator Object
	generator = TrackGenerator.new()
	generator.map_size = Vector2i(512, 512)
	generator.threshold = 0.05
	
	# 2. Assign the generator's texture to the UI
	texture_rect.texture = generator.get_texture()
	
	# 3. Setup UI connections
	$HBoxContainer/VBoxContainer/RegenNoise.pressed.connect(_on_regen_pressed)
	$HBoxContainer/VBoxContainer/Next.pressed.connect(_on_navigate.bind(1))
	$HBoxContainer/VBoxContainer/Prev.pressed.connect(_on_navigate.bind(-1))
	$HBoxContainer/VBoxContainer/GenerateTrack.pressed.connect(_on_generate_final)
	
	_on_regen_pressed()

func _on_regen_pressed():
	generator.regenerate()
	current_loop_index = 0
	_update_preview()

func _on_navigate(step: int):
	if generator.all_valid_loops.is_empty(): return
	var count = generator.all_valid_loops.size()
	current_loop_index = (current_loop_index + step + count) % count
	_update_preview()

func _update_preview():
	if generator.all_valid_loops.is_empty():
		track_line.points = []
		return
	# Use generator's smoothing for UI visualization
	var raw = generator.all_valid_loops[current_loop_index]
	track_line.points = generator._chaikin_smooth(raw, 2)
	track_line.closed = true

func _on_generate_final():
	var curve = generator.create_curve_from_loop(current_loop_index)
	if curve:
		Sim.track.create_track(curve)
