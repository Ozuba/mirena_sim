extends AVehiclePilot
class_name RosPilot

func on_take_control():
	owner.reset_pilot_config()

func pilot(_delta: float):
	owner.steering = owner.get_ros_car_base().steer_angle
	owner.engine_force = owner.get_ros_car_base().gas* owner.ENGINE_F/255
	owner.brake = owner.get_ros_car_base().brake * owner.BRAKE_F/255
