#pragma once

#include <Eigen/Dense>
#include <Eigen/Geometry>  // For quaternions
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/variant/quaternion.hpp>
#include <godot_cpp/variant/transform3d.hpp>

/**
 * @brief Converts a Godot Vector3 to a ROS2 Eigen::Vector3d (NUP).
 */
inline Eigen::Vector3d godot_to_ros2(const godot::Vector3& godot_pos) {
    return Eigen::Vector3d(godot_pos.z, godot_pos.x, godot_pos.y);
}

/**
 * @brief Converts a ROS2 Eigen::Vector3d (NUP) to a Godot Vector3.
 */
inline godot::Vector3 ros2_to_godot(const Eigen::Vector3d& ros2_pos) {
    return godot::Vector3(ros2_pos.y(), ros2_pos.z(), ros2_pos.x());
}

/**
 * @brief Converts a Godot Quaternion to a ROS2 Eigen::Quaterniond (NUP).
 * 
 * Coordinate transformation from Godot (Right-Handed) to ROS2 (NUP Right-Handed):
 * - Swap Y and Z axes.
 * - Invert X and Y to maintain proper rotation.
 */
inline Eigen::Quaterniond godot_to_ros2(const godot::Quaternion& godot_quat) {
    return Eigen::Quaterniond(godot_quat.w, godot_quat.z, godot_quat.x, godot_quat.y);
}

/**
 * @brief Converts a ROS2 Eigen::Quaterniond (NUP) to a Godot Quaternion.
 * 
 * The inverse transformation of `godot_to_ros2`.
 */
inline godot::Quaternion ros2_to_godot(const Eigen::Quaterniond& ros2_quat) {
    return godot::Quaternion(-ros2_quat.x(), ros2_quat.z(), -ros2_quat.y(), ros2_quat.w());
}

/**
 * @brief Converts a Godot Transform3D to a ROS2 Eigen::Isometry3d (NUP).
 */
inline Eigen::Isometry3d godot_to_ros2(const godot::Transform3D& godot_transform) {
    Eigen::Isometry3d ros2_transform = Eigen::Isometry3d::Identity();
    ros2_transform.translate(godot_to_ros2(godot_transform.origin)); // Convert position
    ros2_transform.rotate(godot_to_ros2(godot_transform.basis.get_quaternion())); // Convert rotation
    return ros2_transform;
}

/**
 * @brief Converts a ROS2 Eigen::Isometry3d (NUP) to a Godot Transform3D.
 */
inline godot::Transform3D ros2_to_godot(const Eigen::Isometry3d& ros2_transform) {
    godot::Transform3D godot_transform;
    godot_transform.origin = ros2_to_godot(ros2_transform.translation()); // Convert position
    godot_transform.basis.set_quaternion(ros2_to_godot(Eigen::Quaterniond(ros2_transform.rotation()))); // Convert rotation
    return godot_transform;
}
