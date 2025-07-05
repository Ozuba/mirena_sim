#ifndef GDEXAMPLE_REGISTER_TYPES_H
#define GDEXAMPLE_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>
//ROS2 for context init
#include <rclcpp/rclcpp.hpp>
//Modules
#include "node/ros_node3d.hpp"
#include "node/mirena_car.hpp"
#include "node/mirena_cam.hpp"
#include "node/mirena_lidar.hpp"
#include "node/mirena_imu.hpp"
#include "node/mirena_gps.hpp"
#include "ref_counted/ros_time.hpp"
#include "ref_counted/mirena_ros_bridge.hpp"

using namespace godot;

void mirenasim_init(ModuleInitializationLevel p_level);
void mirenasim_deinit(ModuleInitializationLevel p_level);

#endif // GDEXAMPLE_REGISTER_TYPES_H