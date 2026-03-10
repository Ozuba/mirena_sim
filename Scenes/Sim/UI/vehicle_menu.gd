extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_pilot_mode_item_selected(index: int) -> void:
	var pilot : AVehiclePilot
	match index:
		1:
			pilot = ManualPilot.new(Sim.car)
		2:
			pilot = RosPilot.new(Sim.car)
		3:
			pilot = TrackRailPilot.new(Sim.car)
		4:
			pilot = NoPilot.new(Sim.car)
	Sim.car.set_pilot(pilot)
	

func _on_reset_car_button_pressed() -> void:
	Sim.car.reset_position()
