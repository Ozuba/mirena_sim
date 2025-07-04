#pragma once
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/time.hpp>
#include <rclcpp/rclcpp.hpp>
#include <rosgraph_msgs/msg/clock.hpp>

namespace godot {
class RosTime : public Node {
    GDCLASS(RosTime, Node)

private:
    std::shared_ptr<rclcpp::Node> ros_node;
    rclcpp::Publisher<rosgraph_msgs::msg::Clock>::SharedPtr clock_publisher;

    double m_time_scale = 1.0;
    bool m_use_sim_time = false;

    void publish_clock();
    void update_time_scale(double new_scale);

protected:
    static void _bind_methods();

public:
    RosTime();
    ~RosTime();

    void _ready() override;
    void _physics_process(double delta) override;

    void set_time_scale(double scale);
    double get_time_scale() const;

    void set_use_sim_time(bool use_sim_time);
    bool get_use_sim_time() const;
};
}
