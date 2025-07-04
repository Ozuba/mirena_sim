extends Button

func _ready() -> void:
	self.button_down.connect(func(): Input.action_press("load_track"); Input.action_release("load_track"))
