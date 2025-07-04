extends Button

func _ready() -> void:
	self.button_down.connect(PresetLoader.load_planning)
