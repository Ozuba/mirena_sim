#include "ros_time.hpp"

#include <godot_cpp/classes/engine.hpp>

#include "utility/toolbox.hpp"

#include <cmath>

#define DEFAULT_PERIOD_MS 100

using namespace mirena;
using namespace godot;

RosTime::RosTime() : _ros_node(rclcpp::Node::make_shared("sim_ros_time")),
                     _debug_sim_clock_pub(_ros_node->create_publisher<rosgraph_msgs::msg::Clock>(DEBUG_SIM_CLOCK_TOPIC, 10))
{
}

RosTime::~RosTime()
{
}

void RosTime::publish_sim_clock(double seconds)
{
    rosgraph_msgs::msg::Clock msg;

    uint64_t current_time_ns = static_cast<u_int64_t>(std::round(seconds*1'000'000'000));

    msg.clock.sec = current_time_ns / 1'000'000'000;
    msg.clock.nanosec = (current_time_ns % 1'000'000'000);

    _debug_sim_clock_pub->publish(msg);
}

void mirena::RosTime::spin(){
    rclcpp::spin_some(_ros_node);
}

void RosTime::_bind_methods()
{
    godot::ClassDB::bind_method(D_METHOD("publish_sim_clock", "seconds"), &RosTime::publish_sim_clock);
    godot::ClassDB::bind_method(D_METHOD("spin"), &RosTime::spin);

}
