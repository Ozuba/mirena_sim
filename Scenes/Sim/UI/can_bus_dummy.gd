extends VBoxContainer


@onready var MissionSelector : OptionButton = $MissionSelector/Mission
@onready var DvStartButton : Button = $StartStop/DvStartButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MissionSelector.item_selected.connect(self.on_mission_selected)
	DvStartButton.pressed.connect(self.on_dv_enable_set)
	

func on_mission_selected(item: int) -> void:
	pass

func on_dv_enable_set() -> void:
	if MissionSelector.selected < 0:
		return
	var msg := RosMirenaCommonCanDvConfig.new()
	msg.mission_select.mission = MissionSelector.selected
	Sim.car.get_can_dv_config_pub().publish(msg)
