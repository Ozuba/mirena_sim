extends Control
class_name MirenaHud

@onready var fps_label: Label = $Stats/MarginContainer/VBoxContainer/FpsLabel
@onready var timer_label: Label = $Stats/MarginContainer/VBoxContainer/TimerLabel
@onready var fallen_cones_label: Label = $Stats/MarginContainer/VBoxContainer/FallenConesLabel

func _ready() -> void:
	print("shit ready")

func _process(_delta: float):
	self.update_labels()

func update_labels():
	# Update FPS label
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	# Update Timer label
	timer_label.text = "Timer: %.2f" % (Time.get_ticks_msec() / 1000.0)
	# Update Fallen Cones label
	#fallen_cones_label.text = "Fallen Cones: %d" % SIM.get_stats().get("cones_fallen")

func get_main_menu() -> MainMenu:
	return $MainMenu
