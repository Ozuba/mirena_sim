extends CheckButton

func _ready() -> void:
	self.toggled.connect(self.on_toggle)
