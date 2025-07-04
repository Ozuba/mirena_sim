extends Label

func _ready() -> void:
	# Display Controls
	self.text = "Press < %s > to open menu" % get_first_key_for_action("open_car_menu")
	
func get_first_key_for_action(action: String) -> String:
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode)
	return "None"
	
