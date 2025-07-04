extends Button

func _ready() -> void:
	self.button_down.connect(func(): SIM.get_env().get_track_manager().loadTrack("res://TrackFiles/track.json"))
