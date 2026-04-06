extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_pilot_mode_item_selected(index: int) -> void:
	match index:
		0:
			Sim.car.pilot = MirenaCar.PilotMode.MANUAL
		1:
			Sim.car.pilot = MirenaCar.PilotMode.ROS
		2:
			Sim.car.path = Sim.track.track_path
			Sim.car.pilot = MirenaCar.PilotMode.TRACK_RAIL
		3:
			Sim.car.pilot = MirenaCar.PilotMode.NO_PILOT

	

func _on_reset_car_button_pressed() -> void:
	Sim.car.reset_position()


func _on_as_state_item_selected(index: int) -> void:
	Sim.car.as_status.state = index


func _on_mission_item_selected(index: int) -> void:
	Sim.car.as_status.mission = index
