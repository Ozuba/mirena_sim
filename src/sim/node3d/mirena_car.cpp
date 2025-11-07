#include "mirena_car.hpp"
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void MirenaCarBase::_bind_methods()
{
	ClassDB::bind_method(D_METHOD("has_control_input"), &MirenaCarBase::has_control_input);
	ClassDB::bind_method(D_METHOD("consume_control_input"), &MirenaCarBase::consume_control_input);

	// Wheel Speeds
	ClassDB::bind_method(D_METHOD("set_wheels_speed", "rl", "rr", "fl", "fr"), &MirenaCarBase::set_wheels_speed);
}

//------------------------------------------------------------ GODOT ---------------------------------------------------------//

MirenaCarBase::MirenaCarBase() : has_control_buffered(false),
								 gas_buffer(0), steer_angle_buffer(0)
{
}

void MirenaCarBase::_ros_ready()
{
	rosSub = ros_node->create_subscription<mirena_common::msg::CarControl>(
		CAR_CONTROL_SUB_TOPIC, 10, std::bind(&MirenaCarBase::topic_callback, this, std::placeholders::_1));
	wheelSpeedPub = ros_node->create_publisher<mirena_common::msg::WheelSpeeds>(
		WSS_PUB_TOPIC, 10);
}

bool godot::MirenaCarBase::has_control_input()
{
	return has_control_buffered;
}

Vector2 godot::MirenaCarBase::consume_control_input()
{
	has_control_buffered = false;
	return Vector2(gas_buffer, steer_angle_buffer);
}

void MirenaCarBase::set_wheels_speed(float rl, float rr, float fl, float fr)
{
	w_rl = rl;
	w_rr = rr;
	w_fl = fl;
	w_fr = fr;
}

//------------------------------------------------------------ ROS ---------------------------------------------------------//
void MirenaCarBase::topic_callback(const mirena_common::msg::CarControl::SharedPtr msg)
{
	has_control_buffered = true;
	gas_buffer = msg->gas;
	steer_angle_buffer = msg->steer_angle;
}

void MirenaCarBase::_ros_process(double delta)
{
	auto ws = mirena_common::msg::WheelSpeeds();
	ws.header.stamp = ros_node->now();
	ws.fl = w_fl;
	ws.fr = w_fr;
	ws.rl = w_rl;
	ws.rr = w_rr;
	wheelSpeedPub->publish(ws);
}
