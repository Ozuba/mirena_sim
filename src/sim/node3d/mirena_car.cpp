#include "mirena_car.hpp"
#include <godot_cpp/core/class_db.hpp>


using namespace godot;

void MirenaCarBase::_bind_methods()
{
	// GAS
	ClassDB::bind_method(D_METHOD("get_gas"), &MirenaCarBase::get_gas);
	ClassDB::bind_method(D_METHOD("set_gas", "_gas"), &MirenaCarBase::set_gas);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "gas"), "set_gas", "get_gas");

	// STEER_ANGLE
	ClassDB::bind_method(D_METHOD("get_steer_angle"), &MirenaCarBase::get_steer_angle);
	ClassDB::bind_method(D_METHOD("set_steer_angle", "_steer_angle"), &MirenaCarBase::set_steer_angle);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "steer_angle"), "set_steer_angle", "get_steer_angle");

	// Wheel Speeds
	ClassDB::bind_method(D_METHOD("set_wheels_speed", "rl", "rr", "fl", "fr"), &MirenaCarBase::set_wheels_speed);
}

MirenaCarBase::MirenaCarBase()
{
}

MirenaCarBase::~MirenaCarBase()
{
}

//------------------------------------------------------------ GODOT ---------------------------------------------------------//

void MirenaCarBase::_ros_ready()
{
	// Zero internal variables
	gas = 0;
	steer_angle = 0;
	rosSub = ros_node->create_subscription<mirena_common::msg::CarControl>(
		CAR_CONTROL_SUB_TOPIC, 10, std::bind(&MirenaCarBase::topic_callback, this, std::placeholders::_1));
	wheelSpeedPub = ros_node->create_publisher<mirena_common::msg::WheelSpeeds>(
		WSS_PUB_TOPIC, 10);
}

// Getters and setters
void MirenaCarBase::set_gas(float _gas)
{
	gas = _gas;
}
float MirenaCarBase::get_gas()
{
	return gas;
}

void MirenaCarBase::set_steer_angle(float _steer_angle)
{
	steer_angle = _steer_angle;
}
float MirenaCarBase::get_steer_angle()
{
	return steer_angle;
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
	gas = msg->gas;
	steer_angle = msg->steer_angle;
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
