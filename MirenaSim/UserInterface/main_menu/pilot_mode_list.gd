extends ItemList

func _ready() -> void:
	self.item_selected.connect(self.on_selected)

func on_selected(index: int) -> void:
	var new_pilot: AVehiclePilot
	match index:
		1:
			new_pilot = RosPilot.new(SIM.get_vehicle())
		2:
			new_pilot = ManualPilot.new(SIM.get_vehicle())
		3:
			new_pilot = TrackRailPilot.new(SIM.get_vehicle())
		_:
			new_pilot = NoPilot.new(SIM.get_vehicle())
	SIM.get_vehicle().set_pilot(new_pilot)
	self.update_state()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		self.update_state()

func update_state() -> void:
	self.deselect_all()
	var active_pilot = SIM.get_vehicle().get_current_pilot()
	if active_pilot is NoPilot:
		self.select(0)
	elif active_pilot is RosPilot:
		self.select(1)
	elif active_pilot is ManualPilot:
		self.select(2)
	elif active_pilot is TrackRailPilot:
		self.select(3)
	
