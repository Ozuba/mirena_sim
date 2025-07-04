#include "mirena_imu.hpp"
#include <godot_cpp/core/class_db.hpp>
#include "utility/cframe_helpers.hpp"

using namespace godot;

void MirenaImu::_bind_methods()
{
}

MirenaImu::MirenaImu()
{
}

MirenaImu::~MirenaImu()
{
}

//----------------------------------------------------------[Godot RUntime]----------------------------------------------//
void MirenaImu::_ros_ready()
{
    // Create Publishers
    posePub = ros_node->create_publisher<geometry_msgs::msg::PoseStamped>("car_real_pose", 10);
    imuPub = ros_node->create_publisher<sensor_msgs::msg::Imu>(IMU_PUB_TOPIC, 10);
}

void MirenaImu::_ros_process(double delta)
{

    Transform3D global_tf = get_global_transform();

    // Update Angular Measures
    a_pos = global_tf.basis.get_euler();
    aq_pos = global_tf.basis.get_quaternion();
    // Speed
    a_speed = (a_pos - a_prev_pos) / delta;
    // Accel
    a_accel = (a_speed - a_prev_speed) / delta;
    // Update prevs
    a_prev_pos = a_pos;
    a_prev_speed = a_speed;

    // Update Linear Measures (In IMU frame)
    l_pos = global_tf.origin;
    //Process inertial data in local frame
    // Speed (In local frame)
    l_speed = global_tf.basis.xform_inv((l_pos - l_prev_pos) / delta);
    // Accel
    l_accel = (l_speed - l_prev_speed) / delta;
    // Update prevs
    l_prev_pos = l_pos;
    l_prev_speed = l_speed;

    // Create msgs to send
    auto p_pose = std::make_unique<geometry_msgs::msg::PoseStamped>();
    auto p_imu = std::make_unique<sensor_msgs::msg::Imu>();

    // Convert coordinate frames
    Eigen::Quaterniond orientation = godot_to_ros2(aq_pos);
    Eigen::Vector3d position = godot_to_ros2(l_pos);
    Eigen::Vector3d angular_vel = godot_to_ros2(a_speed);
    Eigen::Vector3d linear_acc = godot_to_ros2(l_accel);

    // Populate the frames
    // Pose
    p_pose->header.stamp = ros_node->now();
    p_pose->header.frame_id = "world";
    p_pose->pose.position.x = position.x();
    p_pose->pose.position.y = position.y();
    p_pose->pose.position.z = position.z();
    p_pose->pose.orientation.x = orientation.x();
    p_pose->pose.orientation.y = orientation.y();
    p_pose->pose.orientation.z = orientation.z();
    p_pose->pose.orientation.w = orientation.w();


    // Orientation
    p_imu->orientation.x = orientation.x();
    p_imu->orientation.y = orientation.y();
    p_imu->orientation.z = orientation.z();
    p_imu->orientation.w = orientation.w();
    p_imu->orientation_covariance = {1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0}; // 3x3 covariance matrix for orientation

    // Angular velocity
    p_imu->angular_velocity.x = angular_vel.x();
    p_imu->angular_velocity.y = angular_vel.y();
    p_imu->angular_velocity.z = angular_vel.z();
    p_imu->angular_velocity_covariance = {1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0}; // 3x3 covariance matrix for angular velocity

    // Linear Acceleration
    p_imu->linear_acceleration.x = linear_acc.x();
    p_imu->linear_acceleration.y = linear_acc.y();
    p_imu->linear_acceleration.z = linear_acc.z();
    p_imu->linear_acceleration_covariance = {1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0}; // 3x3 covariance matrix for linear acceleration

    // IMU Data
    p_imu->header.stamp = ros_node->now();
    p_imu->header.frame_id = ros_node->get_name();

    // Publish all data
    posePub->publish(std::move(p_pose));
    imuPub->publish(std::move(p_imu));
}
