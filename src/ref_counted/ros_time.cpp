#include "ros_time.hpp"

#include <godot_cpp/classes/engine.hpp>

#include "utility/toolbox.hpp"

#define DEFAULT_PERIOD_MS 100

using namespace mirena;
using namespace godot;

RosTime::RosTime() : _ros_node("sim_ros_time"),
                     _debug_sim_clock_pub(_ros_node->create_publisher<builtin_interfaces::msg::Time>(DEBUG_SIM_CLOCK_TOPIC, 10))
{
    set_update_period(DEFAULT_PERIOD_MS);
}

RosTime::~RosTime()
{
}

void RosTime::_publish_sim_clock()
{
    builtin_interfaces::msg::Time msg;

    uint64_t current_time_us = godot::Time::get_singleton()->get_ticks_usec();

    msg.sec = current_time_us / 1000000;
    msg.nanosec = (current_time_us % 1000000) * 1000;

    _debug_sim_clock_pub->publish(msg);
}


void mirena::RosTime::_update()
{
    if (running_on_editor()) {return;}
    _publish_sim_clock();
}

bool mirena::RosTime::has_active_update_timer()
{
    return _update_timer != nullptr;
}

int64_t mirena::RosTime::get_update_period()
{
    return _update_period_ms;
}

void mirena::RosTime::set_update_period(int64_t value)
{
    if (has_active_update_timer()){cancel_update_timer();}
    if(value > 0) {
        _update_period_ms = value;
        _update_timer = _ros_node->create_wall_timer(std::chrono::milliseconds(value), [this](){this->_update();});
    }
}

void mirena::RosTime::cancel_update_timer()
{
    _update_timer->cancel();
    _update_timer = nullptr;
    _update_period_ms = 0;
}


void RosTime::_bind_methods()
{
    godot::ClassDB::bind_method(D_METHOD("set_update_period", "millis"), &RosTime::set_update_period);
    godot::ClassDB::bind_method(D_METHOD("get_update_period"), &RosTime::get_update_period);
    godot::ClassDB::bind_method(D_METHOD("publish_sim_clock"), &RosTime::_publish_sim_clock);
    godot::ClassDB::bind_method(D_METHOD("cancel_update_timer"), &RosTime::cancel_update_timer);

}
