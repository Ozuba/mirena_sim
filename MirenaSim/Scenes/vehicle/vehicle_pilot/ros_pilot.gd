extends AVehiclePilot
class_name RosPilot

func on_take_control():
	owner.reset_pilot_config()

func pilot(_delta: float):
	if owner.get_ros_car_base().has_control_input():
		var control: Vector2 = owner.get_ros_car_base().consume_control_input();
		owner.gas = control.x
		owner.steering = control.y
