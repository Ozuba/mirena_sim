extends FileDialog

func _ready() -> void:
	self.file_selected.connect(self._on_file_dialog_file_selected)

func _on_file_dialog_file_selected(path_: String) -> void:
	print("Selected track path: ", path_)
	SIM.get_env().get_track_manager().clearTrack()# Clears all track from objects
	SIM.get_env().get_track_manager().loadTrack(path_)
