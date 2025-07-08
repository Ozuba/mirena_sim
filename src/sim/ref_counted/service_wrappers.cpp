#include "service_wrappers.hpp"

#include "ros/ros_conversions.hpp"

using namespace mirena;


void mirena::SrvGetEntitiesRequest::_bind_methods()
{
}

void mirena::SrvGetEntitiesResponse::add_entity(const godot::Vector3& pos, const godot::String& type, double confidence)
{
    mirena_common::msg::Entity msg;
    msg.set__position(to_msg(pos));
    msg.set__type(type.utf8().get_data());
    msg.set__confidence(confidence);
    entities.push_back(msg);
}

void mirena::SrvGetEntitiesResponse::_bind_methods()
{
    godot::ClassDB::bind_method(godot::D_METHOD("add_entity", "pos", "type", "confidence"), &SrvGetEntitiesResponse::add_entity);
}

void mirena::SrvGetCarRequest::_bind_methods()
{
}

void mirena::SrvGetCarResponse::set_car_state(const godot::Vector3 &position, const godot::Vector3 &rotation, const godot::Vector3 &lin_speed, const godot::Vector3 &ang_speed, const godot::Vector3 &lin_accel, const godot::Vector3 &ang_accel)
{
    mirena_common::msg::Car msg;
    msg.pose.set__position(to_msg(position));
    msg.pose.set__orientation(to_msg(godot::Quaternion(godot::Basis::from_euler(rotation))));
    msg.velocity.set__linear(to_msg_vector3(lin_speed));
    msg.velocity.set__angular(to_msg_vector3(ang_speed));
    msg.acceleration.set__linear(to_msg_vector3(lin_accel));   
    msg.acceleration.set__angular(to_msg_vector3(ang_accel));
    this->car_state = msg;
}

void mirena::SrvGetCarResponse::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("set_car_state", "pos", "rot", "lin_speed", "ang_speed", "lin_accel", "ang_accel"), &SrvGetCarResponse::set_car_state);
}