extends ItemList

func _ready() -> void:
	self.item_selected.connect(self.on_selected)

func on_selected(index: int) -> void:
	var new_pilot: AVehiclePilot
