extends AVehiclePilot
class_name TrackRailPilot

var _path: Path3D
var _path_follow: PathFollow3D = null

var finished: bool = false

func can_take_control() -> bool:
	return SIM.get_track_manager().has_active_track()

func on_take_control() -> void:
	# Prepare the pathing nodes
	SIM.get_track_manager().track_cleared.connect(self.on_track_cleared, CONNECT_ONE_SHOT)

	self._path = SIM.get_track_manager().get_car_path()
	
	self._path_follow = PathFollow3D.new()
	self._path.add_child(self._path_follow)
	self._path_follow.loop = true
	
	owner.reset_car()
	owner.reset_pilot_config()

func on_lose_control() -> void:
	self.on_track_cleared()

func pilot(delta: float):
	if self.finished: return
	var speed = 10
	
	# Follow the path until completion
	# Move forward along the path
	_path_follow.progress += speed * delta
	# Update vehicle position and orientation
	owner.global_position = _path_follow.global_position
	# Adjust orientation to follow the path's direction
	var path_direction = _path_follow.transform.basis.z
	owner.global_transform = owner.global_transform.looking_at(
		owner.global_position + path_direction, Vector3.UP
	)
	
	if is_equal_approx(self._path_follow.progress_ratio, 1.0):
		self.on_track_cleared()

func on_track_cleared() -> void:
	if self._path != null:
		self._path.remove_child(self._path_follow)
		self._path_follow.queue_free(); 
		self._path_follow = null
		self._path = null
	self.finished = true
