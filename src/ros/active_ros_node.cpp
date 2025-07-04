#include "active_ros_node.hpp"

mirena::ActiveRosNode::ActiveRosNode(const std::string &node_name, const rclcpp::NodeOptions &options) : ActiveRosNode(rclcpp::Node::make_shared(node_name, options))
{
}

mirena::ActiveRosNode::ActiveRosNode(const rclcpp::Node::SharedPtr node) : _node(node)
{
    _spin_thread = std::thread([&](){this->spin();});
}

mirena::ActiveRosNode::~ActiveRosNode()
{
    _shutdown_flag.store(true);
    _spin_thread.join();
}

void mirena::ActiveRosNode::set_paused(bool value)
{
    _paused_flag.store(value);
}

bool mirena::ActiveRosNode::is_paused()
{
    return _paused_flag.load();
}

void mirena::ActiveRosNode::set_spin_period_ms(int64_t value)
{
    _spin_period_ms.store(std::chrono::milliseconds(value));
}

int64_t mirena::ActiveRosNode::get_spin_period_ms()
{
    return _spin_period_ms.load().count();
}

void mirena::ActiveRosNode::spin()
{
    while (_shutdown_flag.load() != true){
        if (_paused_flag.load() != true){
            rclcpp::spin_some(_node);
        }
        std::this_thread::sleep_for(_spin_period_ms.load());
    }
}
