extends Button

func _ready() -> void:
	self.pressed.connect(SIM.get_track_manager().clear_track)
