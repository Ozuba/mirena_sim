extends AVehiclePilot
class_name ManualPilot

## Called when pilot is switched from other pilot to this pilot
func on_take_control():
	owner.reset_pilot_config()

func pilot(delta: float):
	var steering_input := 0
	if Input.is_action_pressed("manual_steer_l"):
		steering_input = 1
	elif Input.is_action_pressed("manual_steer_r"):
		steering_input = -1
	var accelerator_input := Input.get_action_strength("manual_accel")
	var brake_input := Input.get_action_strength("manual_brake")

	# Move Car
	owner.steering = owner.MAX_STEER * smooth_steer(owner.steering/owner.MAX_STEER, steering_input, delta, 2)
	owner.engine_force = owner.ENGINE_F * accelerator_input;
	owner.brake = owner.BRAKE_F * brake_input



static func smooth_steer(current: float, target: float, delta: float, speed: float) -> float:
	# Compute the difference
	var diff = target - current

	# Clamp the difference to the range [-2, 2] just for safety
	diff = clamp(diff, -2.0, 2.0)

	# Compute a proportional factor (0..1), based on how close we are to target
	var t = clamp(abs(diff), 0.0, 1.0)

	# Ease in and out using a smoothstep (cubic) curve
	var _ease = t * t * (3.0 - 2.0 * t)  # smoothstep

	# Move towards target by an eased speed
	current += sign(diff) * _ease * speed * delta

	# Clamp to not overshoot
	if sign(target - current) != sign(diff):
		current = target

	return clamp(current, -1.0, 1.0)
