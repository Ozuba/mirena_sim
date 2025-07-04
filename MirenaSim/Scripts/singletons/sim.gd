extends Node

var _current_scene: SimEnviroment

var _vehicle: MirenaCar
var _hud: MirenaHud

var _stats: Dictionary = {
	"cones_fallen": 0
}

func _ready() -> void:
	var vehicle_scene = preload("res://Scenes/vehicle/mirena_car.tscn")
	self._vehicle = vehicle_scene.instantiate()
	var hud_scene = preload("res://UserInterface/hud/mirena_hud.tscn")
	self._hud = hud_scene.instantiate()
	
	self._start_sim()
	self._parse_arguments()


func _start_sim() -> void:
	self._current_scene = get_tree().current_scene
	self._current_scene.add_child(self._vehicle)
	self._current_scene.add_child(self._hud)


# -------------------------------------------------
# Other
# -------------------------------------------------

func _parse_arguments() -> void:
	var arguments = {}
	#Process user messages
	for argument in OS.get_cmdline_user_args():
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			arguments[argument.trim_prefix("--")] = ""
	# Handle custom track load
	if arguments.has("track"):
		SIM.get_env().get_track_manager().loadTrack(arguments["track"])
	if arguments.has("follow"):
		SIM.get_vehicle().follow_path($Track.path)

# -------------------------------------------------
# Interface
# -------------------------------------------------

func get_vehicle() -> MirenaCar:
	return self._vehicle

func get_hud() -> MirenaHud:
	return self._hud

func get_stats() -> Dictionary:
	return self._stats

func get_env() -> SimEnviroment:
	return self._current_scene

## Shortcut for SIM.get_env().get_track_manager()
func get_track_manager() -> TrackManager:
	return self._current_scene.get_track_manager()
