#pragma once

// GODOT
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "node/ros_node3d.hpp"

// ROS
#include "rclcpp/rclcpp.hpp"

// Standard Ros messages
#include "geometry_msgs/msg/pose_stamped.hpp"
#include "geometry_msgs/msg/twist_stamped.hpp"
#include "geometry_msgs/msg/accel_stamped.hpp"
#include "sensor_msgs/msg/imu.hpp"

#define IMU_PUB_TOPIC "sensors/imu"

namespace godot
{

    class MirenaImu : public RosNode3D
    {
        GDCLASS(MirenaImu, RosNode3D)

    private:
        // Publishers
        rclcpp::Publisher<geometry_msgs::msg::PoseStamped>::SharedPtr posePub;
        rclcpp::Publisher<sensor_msgs::msg::Imu>::SharedPtr imuPub;


        // IMU Linear Calculation Vectors
        Vector3 l_pos;
        Vector3 l_prev_pos;
        Vector3 l_speed;
        Vector3 l_prev_speed;
        Vector3 l_accel;
        // IMU Angular Calculation Vectors
        Quaternion aq_pos; // For pose
        Vector3 a_pos;
        Vector3 a_prev_pos;
        Vector3 a_speed;
        Vector3 a_prev_speed;
        Vector3 a_accel;

    protected:
        static void _bind_methods();

    public:
        // Constructors
        MirenaImu();
        ~MirenaImu();
        // Godot runtime
        void _ros_ready() override;
        void _ros_process(double delta) override;
    };

}
