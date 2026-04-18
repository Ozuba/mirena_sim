extends VBoxContainer


@onready var MissionSelector : OptionButton = $MissionSelector/Mission
@onready var DvStartButton : Button = $StartStop/DvStartButton
@onready var DvStopButton : Button = $StartStop/DvStopButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MissionSelector.item_selected.connect(self.on_mission_selected)
	DvStartButton.pressed.connect(self.on_dv_enable_set.bind(true))
	DvStopButton.pressed.connect(self.on_dv_enable_set.bind(false))
	

func on_mission_selected(item: int) -> void:
	var mission_msg = RosMirenaCommonMissionType.new()
	mission_msg.mission = item
	var msg = RosMirenaCommonCanDvConfig.new()
	msg.multiplexer = 0
	msg.m0_val_mission_req = mission_msg
	Sim.car.get_can_dv_config_pub().publish(msg)

func on_dv_enable_set(value: bool) -> void:
	var msg = RosMirenaCommonCanDvConfig.new()
	msg.multiplexer = 1
	msg.m1_val_driverless_set_enabled = value
	Sim.car.get_can_dv_config_pub().publish(msg)
