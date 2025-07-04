extends Button

func _ready() -> void:
	self.button_down.connect(SIM.get_vehicle().reset_car)
