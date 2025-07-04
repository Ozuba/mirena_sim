#ifndef GDEXAMPLE_REGISTER_TYPES_H
#define GDEXAMPLE_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>
//ROS2 for context init
#include <rclcpp/rclcpp.hpp>
//Modules
#include "node/ros_time.hpp"
#include "node/ros_node3d.hpp"
#include "node/mirena_car.hpp"
#include "node/mirena_cam.hpp"
#include "node/mirena_lidar.hpp"
#include "node/mirena_imu.hpp"
#include "node/mirena_gps.hpp"

using namespace godot;

void mirenasim_init(ModuleInitializationLevel p_level);
void mirenasim_deinit(ModuleInitializationLevel p_level);

#endif // GDEXAMPLE_REGISTER_TYPES_H