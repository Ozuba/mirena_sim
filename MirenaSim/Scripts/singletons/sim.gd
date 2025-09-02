extends Node

var _current_scene: SimEnviroment

var _vehicle: MirenaCar
var _hud: MirenaHud

var _sim_paused_mode: bool = false
var _unpause_timer: SceneTreeTimer
var _sim_clock: float = 0

var _stats: Dictionary = {
	"cones_fallen": 0
}

func _ready() -> void:
	var vehicle_scene = preload("res://Scenes/vehicle/mirena_car.tscn")
	self._vehicle = vehicle_scene.instantiate()
	var hud_scene = preload("res://UserInterface/hud/mirena_hud.tscn")
	self._hud = hud_scene.instantiate()
	
	#ROS.get_ros_publishers()
	
	self._start_sim()
	self._parse_arguments()

func _process(delta: float) -> void:
	self._update_sim_clock(delta)

func _start_sim() -> void:
	self._current_scene = get_tree().current_scene
	self._current_scene.add_child(self._vehicle)
	self._current_scene.add_child(self._hud)
	self._sim_paused_mode = false

func _update_sim_clock(delta: float):
	if not self.get_sim_pause():
		_sim_clock += delta
		ROS.get_ros_time().publish_sim_clock(_sim_clock)

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

func get_sim_clock() -> float:
	return _sim_clock

## If true, pauses the sim
func set_sim_pause(paused: bool) -> void:
	if _sim_paused_mode == paused: return
	var next_processing_mode := Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_ALWAYS
	
	self._sim_paused_mode = paused
	_current_scene.set_deferred("process_mode", next_processing_mode)
	if _unpause_timer:
		_unpause_timer.timeout.disconnect(_on_unpause_timer_timeout)
		_unpause_timer = null

func get_sim_pause() -> bool:
	return _sim_paused_mode

func unpause_for(seconds: float, override: bool = false) -> void:
	if seconds <= 0 or not get_sim_pause(): return
	if _unpause_timer != null:
		if override:
			_unpause_timer.timeout.disconnect(_on_unpause_timer_timeout)
			_unpause_timer = null
		else: 
			return
	
	set_sim_pause(false)
	_unpause_timer = get_tree().create_timer(seconds)
	_unpause_timer.timeout.connect(_on_unpause_timer_timeout)

func _on_unpause_timer_timeout():
	_unpause_timer = null
	set_sim_pause(true)
