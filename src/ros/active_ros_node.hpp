#pragma once

#include "rclcpp/rclcpp.hpp"
#include <thread>
#include <chrono>
#include <atomic>

namespace mirena {
    // DEPRECATED This fucking shit does not work well with subscribers or services, only publishers
    // Self-spinning ros node
    // Wrapper over rclcpp::Node with composition in mind; Interface is the same as a shared_ptr (operator-> for accessing the node) 
    // Handles the node lifecycle and spinning
    class ActiveRosNode {
        public:

        ActiveRosNode(const std::string &node_name, const rclcpp::NodeOptions &options = rclcpp::NodeOptions());
        ActiveRosNode(const rclcpp::Node::SharedPtr node); 
        ~ActiveRosNode();

        void set_paused(bool value);
        bool is_paused();
        void set_spin_period_ms(int64_t value);;
        int64_t get_spin_period_ms();

        rclcpp::Node& operator*() const noexcept { return _node.operator*();};
        rclcpp::Node* operator->() const noexcept { return _node.operator->();};

        private:
        rclcpp::Node::SharedPtr _node;
        std::thread _spin_thread;
        std::atomic<bool> _shutdown_flag = false;
        std::atomic<bool> _paused_flag = false;
        std::atomic<std::chrono::milliseconds> _spin_period_ms = std::chrono::milliseconds(100);

        void spin();
    };
}