extends PanelContainer


func _ready() -> void:
	pass

# Vehicle MENU
func _on_resetcar_button_button_up() -> void:
	Sim.car.reset_position()


func _input(event):
	if event.is_action_pressed("open_sim_menu"):
		visible = !visible


func _on_pilot_mode_item_selected(index: int) -> void:
	var pilot : AVehiclePilot
	match $MarginContainer/VBoxContainer/MenuTabs/VEHICLE/Panel/Vehicle/PilotList/PilotMode.get_item_text(index):
		"Manual":
			pilot = ManualPilot.new(Sim.car)
		"ROS2":
			pilot = RosPilot.new(Sim.car)
		"FollowTrack":
			pilot = TrackRailPilot.new(Sim.car)
	Sim.car.set_pilot(pilot)
