#include "service_wrappers.hpp"

#include "ros/ros_conversions.hpp"

using namespace mirena;

bool mirena::SrvSimSetPauseRequest::get_paused()
{
    return paused;
}

void mirena::SrvSimSetPauseRequest::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("get_paused"), &SrvSimSetPauseRequest::get_paused);
}

double mirena::SrvSimUnpauseForRequest::get_unpause_time()
{
    return unpause_time;
}

void mirena::SrvSimUnpauseForRequest::_bind_methods()
{
	godot::ClassDB::bind_method(godot::D_METHOD("get_unpause_time"), &SrvSimUnpauseForRequest::get_unpause_time);
}