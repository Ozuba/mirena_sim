extends AVehiclePilot
class_name TrackRailPilot

var _path: Path3D
var _path_follow: PathFollow3D = null

var finished: bool = false
var speed: float = 10.0

func can_take_control() -> bool:
	# Only allow control if the track exists in the SIM singleton
	return Sim.track != null and Sim.track.track_path != null

func on_take_control() -> void:
	# 1. Fetch path from singleton
	self._path = Sim.track.track_path
	
	# 2. Setup PathFollow3D
	self._path_follow = PathFollow3D.new()
	self._path.add_child(self._path_follow)
	
	# IMPORTANT: Force a transform update so global_position is valid 
	# before the first pilot() call.
	self._path_follow.force_update_transform()
	
	# 3. Configure behavior
	self._path_follow.loop = false # Change to true if you want it to repeat
	self._path_follow.loop = false # Change to true if you want it to repeat

	self.finished = false
	
	# 4. Initialize Vehicle
	if owner:
		owner.reset_position()
		owner.reset_pilot_config()

func on_lose_control() -> void:
	self.on_track_cleared()

func pilot(delta: float):
	# Safety Gate: Ensure we are in a valid state to calculate physics
	if self.finished or _path_follow == null:
		return
		
	if not _path_follow.is_inside_tree():
		return

	# Move forward along the path
	_path_follow.progress += speed * delta
	
	# Update vehicle position
	owner.global_position = _path_follow.global_position
	
	# Update orientation:
	# PathFollow3D already handles "looking ahead" via its own transform.
	# We copy the basis (rotation/scale) directly from the follower.
	owner.global_basis = _path_follow.global_basis


func on_track_cleared() -> void:
	# Flag as finished first to stop the pilot() loop
	self.finished = true
	
	# Safe removal of the dynamic node
	if is_instance_valid(_path_follow) and _path_follow.get_parent():
		_path_follow.get_parent().remove_child(_path_follow)
		_path_follow.queue_free()
	
	_path_follow = null
	_path = null
	
