extends FileDialog

func _ready() -> void:
	self.file_selected.connect(self._on_file_dialog_file_selected)

func _on_file_dialog_file_selected(path_: String) -> void:
	print("Selected track path: ", path_)
