#pragma once
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/time.hpp>

#include <rosgraph_msgs/msg/clock.hpp>
#include "rclcpp/rclcpp.hpp"

#define DEBUG_SIM_CLOCK_TOPIC "/clock"

namespace mirena {
class RosTime : public godot::RefCounted {
    GDCLASS(RosTime, godot::RefCounted)

private:
    rclcpp::Node::SharedPtr _ros_node;
    rclcpp::Publisher<rosgraph_msgs::msg::Clock>::SharedPtr _debug_sim_clock_pub;

    void publish_sim_clock(double seconds);

    void spin();

protected:
    static void _bind_methods();

public:
    RosTime();
    ~RosTime();

};
}
