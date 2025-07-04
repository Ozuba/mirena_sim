extends CanvasLayer
class_name MirenaHud

var timer = 0.0

@onready var fps_label: Label = $PanelContainer/MarginContainer/VBoxContainer/FpsLabel
@onready var fallen_cones_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TimerLabel
@onready var timer_label: Label = $PanelContainer/MarginContainer/VBoxContainer/FallenConesLabel

func _process(delta: float):
	self.process_inputs()
	self.update_labels(delta)

func process_inputs():
	if Input.is_action_just_pressed("open_car_menu"):
		if $MainMenuNode.visible:
			$MainMenuNode.hide()
		else:
			$MainMenuNode.show()
			# Check if the "m" key is pressed
	if Input.is_action_just_pressed("load_track"):
		# Show the FileDialog
		print("pressedlmao")
		if $TrackSelection.visible:
			$TrackSelection.hide()
		else:
			$TrackSelection.popup_centered()

func update_labels(delta: float):
	# Update FPS label
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	# Update Timer label
	self.timer += delta
	timer_label.text = "Timer: %.2f" % self.timer

	# Update Fallen Cones label
	fallen_cones_label.text = "Fallen Cones: %d" % SIM.get_stats().get("cones_fallen")
