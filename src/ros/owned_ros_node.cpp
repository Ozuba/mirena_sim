#include "owned_ros_node.hpp"

mirena::OwnedRosNode::OwnedRosNode(const std::string &node_name, const rclcpp::NodeOptions &options = rclcpp::NodeOptions()) : _node(rclcpp::Node::make_shared(node_name, options))
{
    _spin_thread = std::thread([&](){this->spin();});
}

mirena::OwnedRosNode::~OwnedRosNode()
{
    _shutdown_flag.store(true);
    _spin_thread.join();
}

void mirena::OwnedRosNode::set_paused(bool value)
{
    _paused_flag.store(value);
}

bool mirena::OwnedRosNode::get_paused()
{
    return _paused_flag.load();
}

void mirena::OwnedRosNode::set_spin_period_ms(int64_t value)
{
    _spin_period_ms.store(std::chrono::milliseconds(value));
}

int64_t mirena::OwnedRosNode::get_spin_period_ms()
{
    return _spin_period_ms.load().count();
}

void mirena::OwnedRosNode::spin()
{
    while (_shutdown_flag.load() != true){
        if (_paused_flag.load() != true){
            rclcpp::spin_some(_node);
        }
        std::this_thread::sleep_for(_spin_period_ms.load());
    }
}
