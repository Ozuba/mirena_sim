#pragma once
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/time.hpp>

#include <builtin_interfaces/msg/time.h>

#include <ros/active_ros_node.hpp>

#define DEBUG_SIM_CLOCK_TOPIC "/clock"

namespace mirena {
class RosTime : public godot::RefCounted {
    GDCLASS(RosTime, godot::RefCounted)

private:
    ActiveRosNode _ros_node;
    rclcpp::Publisher<builtin_interfaces::msg::Time>::SharedPtr _debug_sim_clock_pub;

    rclcpp::TimerBase::SharedPtr _update_timer;
    int64_t _update_period_ms = 0;

    void _publish_sim_clock();

    void _update();

protected:
    static void _bind_methods();

public:
    RosTime();
    ~RosTime();

    bool has_active_update_timer();
    int64_t get_update_period();
    void set_update_period(int64_t millis);
    void cancel_update_timer();
};
}
