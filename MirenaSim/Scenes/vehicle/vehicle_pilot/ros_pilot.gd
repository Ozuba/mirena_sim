extends AVehiclePilot
class_name RosPilot

func on_take_control():
	owner.reset_pilot_config()

func pilot(_delta: float):
	owner.steering = owner.get_ros_car_base().steer_angle
	owner.gas = owner.get_ros_car_base().gas
