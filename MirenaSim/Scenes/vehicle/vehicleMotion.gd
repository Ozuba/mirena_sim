extends VehicleBody3D
class_name MirenaCar

const ENGINE_F = 900
const BRAKE_F = 20
const MAX_STEER = deg_to_rad(30)

#Control Mode
enum ControlMode {ROS, STEERING_WHEEL}
var drive_mode = ControlMode.ROS
var _active_pilot: AVehiclePilot = RosPilot.new(self)

# CarStateBroadcaster
var state_broadcaster:= CarStateBroadcaster.new(self)

# Position Wrapping
var do_pos_wraping: bool = true;
var x_limits: Vector2 = Vector2i(-45, 45)
var z_limits: Vector2 = Vector2i(-45, 45)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Doing this ensures that all dumps are calculated righfully
	RenderingServer.frame_post_draw.connect(_on_post_render)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#Handle all inputs
	if Input.is_action_just_pressed("driving_mode"):
		if self.drive_mode == ControlMode.ROS:
			self.drive_mode = ControlMode.STEERING_WHEEL
			$UserCam.current = true
			self.set_pilot(ManualPilot.new(self))
		else:
			self.drive_mode = ControlMode.STEERING_WHEEL
			$UserCam.current = false
			self.set_pilot(RosPilot.new(self))

	if Input.is_action_just_pressed("autofollow"):
		self.set_pilot(TrackRailPilot.new(self))
	
	if self.do_pos_wraping: self._perform_pos_wrapping()
	
	$MirenaCarBase.set_wheels_speed(
		$RL_WHEEL.get_rpm()*PI/30,
		$RR_WHEEL.get_rpm()*PI/30,
		$FL_WHEEL.get_rpm()*PI/30,
		$FL_WHEEL.get_rpm()*PI/30
	)

func _physics_process(delta: float) -> void:
	self._active_pilot.pilot(delta)
	self.state_broadcaster.update(delta)

func set_pose(pos : Vector3, theta : float = 0, reset_vel: bool = false) -> void:
	if reset_vel:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	await get_tree().process_frame #Let the phisics state propagate
	#Update transform
	set_deferred("global_transform", Transform3D(Basis(Vector3.UP, theta), pos))
	set_deferred("global_transform", Transform3D(Basis(Vector3.UP, theta), pos))

func _perform_pos_wrapping():
	if self.is_outside_boundaries():
		#print("IS outside", self.position)
		var new_pos = self.position

		new_pos.x = wrap_float(new_pos.x, x_limits.x, x_limits.y)
		new_pos.z = wrap_float(new_pos.z, z_limits.x, z_limits.y)
		
		self.set_pose(new_pos, self.rotation.y, false)

func is_outside_boundaries() -> bool:
	return self.position.x < self.x_limits.x or self.position.x > self.x_limits.y or self.position.z < self.z_limits.x or self.position.z > self.z_limits.y

func _on_post_render():
	if Input.is_action_just_pressed("dump_yolo"):
		$MirenaCarBase/MirenaCam.dump_group_bbox_to_yolo("Cones")
	
	if Input.is_action_just_pressed("dump_keypoints"):
		$MirenaCarBase/MirenaCam.dump_group_keypoints("Cones")

# -----------------------------------------
# Static
# -----------------------------------------

static func wrap_float(value: float, min_value: float, max_value: float) -> float:
	var abs_range = max_value - min_value
	var result = fmod(value - min_value, abs_range)
	if result < 0:
		result += abs_range
	return result + min_value
	
# -----------------------------------------
# Interface
# -----------------------------------------

func set_do_position_wrapping(value: bool) -> void:
	do_pos_wraping = value

func get_do_position_wrapping() -> bool:
	return do_pos_wraping

func toggle_do_position_wrapping() -> void:
	do_pos_wraping = !do_pos_wraping;

func reset_car() -> void:
	set_pose(Vector3(0, 0.1, 0), 0, true)

func get_ros_car_base() -> MirenaCarBase:
	return $MirenaCarBase

func set_pilot(other_pilot: AVehiclePilot) -> void:
	if self._active_pilot == other_pilot: return
	if not other_pilot.can_take_control(): return
	self._active_pilot.on_lose_control()
	other_pilot.on_take_control()
	self._active_pilot = other_pilot

func get_current_pilot() -> AVehiclePilot:
	return self._active_pilot

# Reset all car driving-related car attributes and set the "NoPilot" pilot
func reset_pilot_config() -> void:
	# Set the pilot to no pilot
	self._active_pilot = NoPilot.new(self)
	
	# Reset attributes
	self.freeze = false
