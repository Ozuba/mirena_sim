extends Control
class_name MirenaHud

@onready var fps_label: Label = $Stats/MarginContainer/VBoxContainer/FpsLabel
@onready var timer_label: Label = $Stats/MarginContainer/VBoxContainer/TimerLabel
@onready var fallen_cones_label: Label = $Stats/MarginContainer/VBoxContainer/FallenConesLabel

func _input(event):
	# Toggle Visibility
	if event.is_action_pressed("open_sim_menu"):
		visible = !visible

func _ready() -> void:
	%ConsensusSpoofEnable.toggled.connect(func(value) : Sim.car._pipeline_spoofer._consensus.do_rv_spoof = value)
	%PerceptionSpoofEnable.toggled.connect(func(value) : Sim.car._pipeline_spoofer._perception.do_rv_spoof = value)
	%SlamSpoofEnable.toggled.connect(func(value) : Sim.car._pipeline_spoofer._slam.do_rv_spoof = value)
	%PlanningSpoofEnable.toggled.connect(func(value) : Sim.car._pipeline_spoofer._planning.do_rv_spoof = value)
