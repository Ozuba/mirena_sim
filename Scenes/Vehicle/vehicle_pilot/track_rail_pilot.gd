extends AVehiclePilot
class_name TrackRailPilot

var _path: Path3D
var _path_follow: PathFollow3D = null

var finished: bool = false
var speed: float = 10.0
var rotation_speed: float = 5.0 # Increased for snappier response
var look_ahead_distance: float = 3.0 # Meters ahead for orientation

func can_take_control() -> bool:
	return Sim.track != null and Sim.track.track_path != null

func on_take_control() -> void:
	_path = Sim.track.track_path
	
	_path_follow = PathFollow3D.new()
	_path_follow.rotation_mode = PathFollow3D.ROTATION_ORIENTED
	_path_follow.use_model_front = true 
	_path_follow.loop = false
	
	_path.add_child(_path_follow)
	_path_follow.force_update_transform()

	finished = false
	
	if owner:
		owner.reset_position()
		owner.reset_pilot_config()

func on_lose_control() -> void:
	on_track_cleared()

func pilot(delta: float) -> void:
	if finished or _path_follow == null or not _path_follow.is_inside_tree():
		return

	# 1. Update Path Follower position
	_path_follow.progress += speed * delta
	
	# 2. Physics Movement (Current Position Target)
	var target_pos = _path_follow.global_position
	var motion = target_pos - owner.global_position
	
	var collision = owner.move_and_collide(motion)
	if collision:
		var remainder = collision.get_remainder().slide(collision.get_normal())
		owner.move_and_collide(remainder)

	# 3. Look-Ahead Orientation
	# We sample the path 3m ahead of current progress for a smoother 'curve' feel
	var look_ahead_progress = _path_follow.progress + look_ahead_distance
	var look_target = _path.curve.sample_baked_with_rotation(look_ahead_progress, true)
	
	# Convert local path-space transform to global
	var global_look_transform = _path.global_transform * look_target
	var target_basis = global_look_transform.basis * Basis(Vector3.UP, PI) # Flip rotation
	
	# Slerp the basis for smoothness, using orthonormalized() to prevent matrix corruption
	owner.global_transform.basis = owner.global_transform.basis.slerp(
		target_basis, 
		rotation_speed * delta
	).orthonormalized()

	if _path_follow.progress_ratio >= 0.99:
		on_track_cleared()

func on_track_cleared() -> void:
	finished = true
	if is_instance_valid(_path_follow):
		_path_follow.queue_free()
	
	_path_follow = null
	_path = null
