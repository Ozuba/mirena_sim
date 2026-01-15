extends VehicleBody3D
class_name MirenaCar


const POWER_LIM = 80000 # W
const MOTOR_PEAK_TRQ = 100 # Nm
const GEAR_RATIO = 5 # 1:5
const WHEEL_RADIUS = 0.23 # m
const BRAKE_F = 20
const MAX_STEER = deg_to_rad(30)

var _active_pilot: AVehiclePilot = ManualPilot.new(self)

# Overloaded longitudinal actuator GAS
@export var gas: float

# Called when the node enters the scene tree for the first time.
func _ready():
	# Register cameras in sim
	Sim.register_camera("TPCam",$TPCam)
	Sim.register_camera("FPCam",$FPCam)
	# Register car in Sim
	Sim.car = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Execute control action (This mimics the low level controller)
	# Ensure power limit
	var u = (global_transform.basis.inverse() * linear_velocity).z # Get longitudinal speed
	
	# Force limits
	var max_fx_motor = MOTOR_PEAK_TRQ*GEAR_RATIO/(WHEEL_RADIUS)
	
	# Regen controller (Prevents going backwards)
	var max_fx_regen = 0.5*(1+tanh(u/0.01))*max_fx_motor
	
	var fx = min(gas,0)* max_fx_regen + max(gas,0)*max_fx_motor
	# Set wheel torques
	$RL_WHEEL.engine_force = fx/2
	$RR_WHEEL.engine_force = fx/2
	
	# Reset position if falling out of track
	if position.y < -1:
		reset_position()


func _physics_process(delta: float) -> void:
	self._active_pilot.pilot(delta)

func set_pose(pos : Vector3, theta : float = 0, reset_vel: bool = false) -> void:
	if reset_vel:
		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
	await get_tree().process_frame #Let the phisics state propagate
	#Update transform
	set_deferred("global_transform", Transform3D(Basis(Vector3.UP, theta), pos))
	set_deferred("global_transform", Transform3D(Basis(Vector3.UP, theta), pos))


# -----------------------------------------
# Interface
# -----------------------------------------

func reset_position() -> void:
	var pos = Vector3(0, 0.1, 0)
	var phi = 0
	if Sim.track.track_curve:
		var start_gate = Sim.track.get_gate_positions()[0]
		pos = Vector3(start_gate["x"],start_gate["y"],start_gate["z"])
		phi = start_gate["phi"]
	set_pose(pos, phi, true)
	self.gas = 0;
	self.steering = 0;
	self.brake = 0;

## KEEP IT FOR THE MEMES
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
