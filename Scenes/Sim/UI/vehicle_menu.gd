extends MarginContainer

# Text for each MissionInfo.status value (index matches mirena_common/MissionInfo constants).
const MISSION_STATUS_NAMES := ["INACTIVE", "CONFIGURING", "READY", "RUNNING", "FINISHED", "FAILED"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta):
	var ms_idx: int = Sim.car._mission_info.status
	var ms_text: String = MISSION_STATUS_NAMES[ms_idx] if ms_idx >= 0 and ms_idx < MISSION_STATUS_NAMES.size() else "UNKNOWN"
	$Vehicle/MissionStatus/Label.text = "MISSION_STATUS: " + ms_text

func _on_pilot_mode_item_selected(index: int) -> void:
	match index:
		0:
			Sim.car.pilot = MirenaCar.PilotMode.MANUAL
		1:
			Sim.car.pilot = MirenaCar.PilotMode.ROS
		2:
			Sim.car.path = Sim.track.track_path
			Sim.car.pilot = MirenaCar.PilotMode.TRACK_RAIL
		3:
			Sim.car.pilot = MirenaCar.PilotMode.NO_PILOT

	

func _on_reset_car_button_pressed() -> void:
	Sim.car.reset_position()


func _on_as_state_item_selected(index: int) -> void:
	# Dropdown item ids match the AsInfo.AS_STATUS_* constants.
	Sim.car._as_info.status = index


func _on_mission_item_selected(index: int) -> void:
	# Dropdown item ids match the AsInfo.AS_MISSION_* constants.
	Sim.car._as_info.mission = index
