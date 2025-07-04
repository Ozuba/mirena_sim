#include "ros_time.hpp"
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <rclcpp/parameter_client.hpp>

namespace godot
{

    RosTime::RosTime()
    {
    }

    RosTime::~RosTime()
    {
    }

    void RosTime::_ready()
    {
        if (!Engine::get_singleton()->is_editor_hint())
        { // Comprobamos si estamos en el editor
            // Create ROS2 node
            ros_node = rclcpp::Node::make_shared("MirenaTime");

            // Create clock publisher
            clock_publisher = ros_node->create_publisher<rosgraph_msgs::msg::Clock>("/clock", 10);
        }
    }

    void RosTime::_physics_process(double delta)
    {
        if (!Engine::get_singleton()->is_editor_hint())
        { // Comprobamos si estamos en el editor
            if (ros_node)
            {
                rclcpp::spin_some(ros_node);
                // Publish clock if sim time is enabled
                if (m_use_sim_time)
                {
                    publish_clock();
                }
            }
        }
    }

    void RosTime::publish_clock()
    {
        rosgraph_msgs::msg::Clock clock_msg;

        // Use Godot's time with scaling
        uint64_t current_time_us = Time::get_singleton()->get_ticks_usec() * m_time_scale;

        clock_msg.clock.sec = current_time_us / 1000000;
        clock_msg.clock.nanosec = (current_time_us % 1000000) * 1000;

        if (clock_publisher)
        {
            clock_publisher->publish(clock_msg);
        }
    }

    void RosTime::set_time_scale(double scale)
    {
        m_time_scale = scale;
            Engine::get_singleton()->set_time_scale(scale);
    }

    double RosTime::get_time_scale() const
    {
        return m_time_scale;
    }

    void RosTime::set_use_sim_time(bool use_sim_time)
    {
        m_use_sim_time = use_sim_time;
    }

    bool RosTime::get_use_sim_time() const
    {
        return m_use_sim_time;
    }

    void RosTime::_bind_methods()
    {
        ClassDB::bind_method(D_METHOD("set_time_scale", "scale"), &RosTime::set_time_scale);
        ClassDB::bind_method(D_METHOD("get_time_scale"), &RosTime::get_time_scale);
        ClassDB::bind_method(D_METHOD("set_use_sim_time", "use_sim_time"), &RosTime::set_use_sim_time);
        ClassDB::bind_method(D_METHOD("get_use_sim_time"), &RosTime::get_use_sim_time);

        ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "time_scale", PROPERTY_HINT_RANGE, "0.1,10,0.1"), "set_time_scale", "get_time_scale");
        ADD_PROPERTY(PropertyInfo(Variant::BOOL, "use_sim_time"), "set_use_sim_time", "get_use_sim_time");
    }

}