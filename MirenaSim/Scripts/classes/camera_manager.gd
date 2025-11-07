extends Node
class_name CameraManager

class Names:
	static var FreeCam = &"FreeCam"
	static var FPCam = &"FPCam"
	static var TPCam = &"TPCam"

var _cameras : Dictionary[StringName, Camera3D]
var _currently_active : Camera3D = null
var _currently_active_name : StringName = &""
var _camera_toggle_cycle_progress := 0

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("alternate_camera"):
		alternate_camera()

func register_camera(_name: StringName, camera: Camera3D) -> void:
	_cameras.set(_name, camera)
	
func focus_camera(_name: StringName) -> void:
	if _currently_active_name == name: return
	if _currently_active != null:
		set_camera_focus(false)
		_currently_active.current = false
		
	var cam : Camera3D = _cameras.get(_name)
	if cam != null:
		_currently_active = cam
		cam.current= true;
		set_camera_focus(true)

func get_cameras() -> Array[StringName]:
	return _cameras.keys()

func alternate_camera() -> void:
	if _cameras.size() <= 0: return
	_camera_toggle_cycle_progress = (_camera_toggle_cycle_progress + 1) % _cameras.size()
	focus_camera(_cameras.keys().get(_camera_toggle_cycle_progress))

func set_camera_focus(value: bool):
	if _currently_active.has_method("set_focus"): _currently_active.set_focus(value)
