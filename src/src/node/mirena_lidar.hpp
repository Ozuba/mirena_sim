#ifndef MIRENA_LIDAR_H
#define MIRENA_LIDAR_H

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/engine.hpp>
#include "node/ros_node3d.hpp"
#include <omp.h>

// ROS
#include <rclcpp/rclcpp.hpp>
#include <sensor_msgs/msg/point_cloud2.hpp>

#define LIDAR_PUB_TOPIC "sensors/lidar"

namespace godot
{
    class MirenaLidar : public RosNode3D
    {
        GDCLASS(MirenaLidar, RosNode3D)

    private:
        // ROS publisher
        rclcpp::Publisher<sensor_msgs::msg::PointCloud2>::SharedPtr pub;

        double max_range;
        int horizontal_resolution;
        int vertical_resolution;
        double vertical_fov;
        double horizontal_fov;
        uint32_t collision_mask;
        double noise_dev;

    protected:
        static void _bind_methods();

    public:
        MirenaLidar();
        ~MirenaLidar();

        void _ros_ready() override;
        void _ros_process(double delta)override;
        // Getters and Setters
        void set_refresh_rate(double r_rate);
        double get_refresh_rate() const;

        void set_max_range(double p_range);
        double get_max_range() const;

        void set_noise_dev(double p_dev);
        double get_noise_dev() const;

        void set_horizontal_resolution(int p_resolution);
        int get_horizontal_resolution() const;

        void set_vertical_resolution(int p_resolution);
        int get_vertical_resolution() const;

        void set_vertical_fov(double p_fov);
        double get_vertical_fov() const;

        void set_horizontal_fov(double p_fov);
        double get_horizontal_fov() const;

        void set_collision_mask(uint32_t p_mask);
        uint32_t get_collision_mask() const;

        void scan();
    };

}

#endif // MIRENA_LIDAR
