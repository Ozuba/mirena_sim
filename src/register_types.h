#ifndef GDEXAMPLE_REGISTER_TYPES_H
#define GDEXAMPLE_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>
//ROS2 for context init
#include <rclcpp/rclcpp.hpp>
//Modules
#include "sim/node3d/ros_node3d.hpp"
#include "sim/node3d/mirena_car.hpp"
#include "sim/node3d/mirena_cam.hpp"
#include "sim/node3d/mirena_lidar.hpp"
#include "sim/node3d/mirena_imu.hpp"
#include "sim/node3d/mirena_gps.hpp"
#include "sim/ref_counted/ros_time.hpp"
#include "sim/ref_counted/mirena_ros_bridge.hpp"

using namespace godot;

void mirenasim_init(ModuleInitializationLevel p_level);
void mirenasim_deinit(ModuleInitializationLevel p_level);

#endif // GDEXAMPLE_REGISTER_TYPES_H