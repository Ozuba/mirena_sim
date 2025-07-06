#include "mirena_car.hpp"
#include <godot_cpp/core/class_db.hpp>
#include <tf2/LinearMath/Quaternion.h>

namespace util
{
	inline geometry_msgs::msg::Vector3 to_ros_vec(const godot::Vector3 &gd_vec3)
	{
		geometry_msgs::msg::Vector3 msg;
		msg.set__x(gd_vec3[2]);
		msg.set__y(gd_vec3[0]);
		msg.set__z(gd_vec3[1]);
		return msg;
	}

	inline geometry_msgs::msg::Pose to_ros_pose(const godot::Vector3 &gd_pos, const godot::Vector3 &gd_rot)
	{
		geometry_msgs::msg::Pose msg;
		msg.position.set__x(gd_pos[2]);
		msg.position.set__y(gd_pos[0]);
		msg.position.set__z(gd_pos[1]);

		tf2::Quaternion q;
		geometry_msgs::msg::Quaternion ros_q;
		q.setRPY(gd_rot[2], gd_rot[0], gd_rot[1]);
		msg.orientation.set__x(q.getX());
		msg.orientation.set__y(q.getY());
		msg.orientation.set__z(q.getZ());
		msg.orientation.set__w(q.getW());

		return msg;
	}
}

using namespace godot;

void MirenaCarBase::_bind_methods()
{
	// GAS
	ClassDB::bind_method(D_METHOD("get_gas"), &MirenaCarBase::get_gas);
	ClassDB::bind_method(D_METHOD("set_gas", "_gas"), &MirenaCarBase::set_gas);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "gas"), "set_gas", "get_gas");
	// BRAKE
	ClassDB::bind_method(D_METHOD("get_brake"), &MirenaCarBase::get_brake);
	ClassDB::bind_method(D_METHOD("set_brake", "_brake"), &MirenaCarBase::set_brake);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "brake"), "set_brake", "get_brake");
	// STEER_ANGLE
	ClassDB::bind_method(D_METHOD("get_steer_angle"), &MirenaCarBase::get_steer_angle);
	ClassDB::bind_method(D_METHOD("set_steer_angle", "_steer_angle"), &MirenaCarBase::set_steer_angle);
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "steer_angle"), "set_steer_angle", "get_steer_angle");

	// Wheel Speeds
	ClassDB::bind_method(D_METHOD("set_wheels_speed", "rl", "rr", "fl", "fr"), &MirenaCarBase::set_wheels_speed);

	// Debug state broadcast:
	ClassDB::bind_method(D_METHOD("ros_broadcast_car_state", "position", "rotation", "lin_speed", "ang_speed", "lin_accel", "ang_accel"), &MirenaCarBase::broadcast_car_state);
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
	brake = 0;
	steer_angle = 0;
	rosSub = ros_node->create_subscription<mirena_common::msg::CarInput>(
		CAR_INPUT_SUB_TOPIC, 10, std::bind(&MirenaCarBase::topic_callback, this, std::placeholders::_1));
	wheelSpeedPub = ros_node->create_publisher<mirena_common::msg::WheelSpeeds>(
		WSS_PUB_TOPIC, 10);
	debugCarStatePub = ros_node->create_publisher<mirena_common::msg::Car>(
		DEBUG_CAR_STATE_PUB_TOPIC, 10);
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
void MirenaCarBase::set_brake(float _brake)
{
	brake = _brake;
}
float MirenaCarBase::get_brake()
{
	return brake;
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

void MirenaCarBase::broadcast_car_state(
	const Vector3& position, const Vector3& rotation,
	const Vector3& lin_speed, const Vector3& ang_speed,
	const Vector3& lin_accel, const Vector3& ang_accel
){
	mirena_common::msg::Car car_state;

	// Populate Header
	car_state.header.set__frame_id(FIXED_FRAME_NAME);
	car_state.header.set__stamp(this->ros_node->now());
	
	// Populate Mesage
	car_state.set__pose(util::to_ros_pose(position, rotation));
	car_state.velocity.set__linear(util::to_ros_vec(lin_speed));
	car_state.velocity.set__angular(util::to_ros_vec(ang_speed));
	car_state.acceleration.set__linear(util::to_ros_vec(lin_accel));
	car_state.acceleration.set__angular(util::to_ros_vec(ang_accel));
	this->debugCarStatePub->publish(car_state);
}

//------------------------------------------------------------ ROS ---------------------------------------------------------//
void MirenaCarBase::topic_callback(const mirena_common::msg::CarInput::SharedPtr msg)
{
	gas = msg->gas;
	brake = msg->brake;
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
