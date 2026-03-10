extends Node

# -------------------------------------------------
# Global objects
# -------------------------------------------------

var _stats: Dictionary = {
	"cones_fallen": 0
}

var current_scene: Node

var car : MirenaCar
var track : Track
var arguments : Dictionary


# -------------------------------------------------
# Runtime
# -------------------------------------------------


func _ready() -> void:	
	self._parse_arguments()
	
	self.current_scene = get_tree().current_scene
	# Añadir el nodo de debugging
	var SimDebug = load("res://Scenes/Sim/sim_debug.gd")
	add_child.call_deferred(SimDebug.new())

	
func _input(event):
	# Camera Toggle
	if event.is_action_pressed("alternate_camera"):
		var next_cam = get_next_id()
		if next_cam != "":
			switch_to_camera(next_cam)
			print("Switched to: ", next_cam)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Ctrl+C or Close detected. Shutting down...")
		# Perform cleanup here (save files, close sockets, etc.)
		get_tree().quit()

# -------------------------------------------------
# Argument Parser
# -------------------------------------------------

func _parse_arguments() -> void:
	var arguments = {}
	#Process user messages
	for argument in OS.get_cmdline_args():
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			# Options without an argument will be present in the dictionary,
			# with the value set to an empty string.
			arguments[argument.trim_prefix("--")] = ""
	self.arguments = arguments
	print(arguments)

	#else:
		
	# Hndle custom track load
	#if arguments.has("track"):
	#	SIM.get_env().get_track_manager().loadTrack(arguments["track"])
	#if arguments.has("follow"):
	#	SIM.get_vehicle().follow_path($Track.path)

	
# -------------------------------------------------
# Camera management
# -------------------------------------------------

# Dictionary to store cameras by a unique String ID
var _cameras: Dictionary = {}
var _active_id: String = ""

func register_camera(id: String, camera: Camera3D):
	_cameras[id] = camera
	# If this is the first camera registered, make it active
	if _cameras.size() == 1:
		switch_to_camera(id)
		
func unregister_camera(id: String):
	if _cameras.has(id):
		_cameras.erase(id)
		
func switch_to_camera(id: String):
	if not _cameras.has(id):
		push_warning("Camera ID '" + id + "' not found in SIM.")
		return

	_active_id = id
	
	# Loop through all registered cameras and toggle the 'current' property
	for cam_id in _cameras:
		var cam = _cameras[cam_id]
		if is_instance_valid(cam):
			cam.current = (cam_id == id)
			
func get_next_id() -> String:
	var keys = _cameras.keys()
	if keys.is_empty(): return ""
	
	var current_index = keys.find(_active_id)
	var next_index = (current_index + 1) % keys.size()
	return keys[next_index]
