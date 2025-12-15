#ifndef MIRENA_LIDAR_H
#define MIRENA_LIDAR_H

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/engine.hpp>

// --- NEW REQUIRED INCLUDE FOR PackedVector3Array ---
#include <godot_cpp/variant/packed_vector3_array.hpp> 

#include"sim/node3d/ros_node3d.hpp"
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
        
        // --- NEW MEMBER VARIABLE FOR PERFORMANCE IMPROVEMENT ---
        // Stores the calculated direction vectors in the sensor's local frame.
        // This avoids repeated trigonometric calculations in the scan loop.
        PackedVector3Array precalculated_local_directions;

        // --- NEW HELPER FUNCTION ---
        // Calculates and populates the precalculated_local_directions array.
        // Must be called whenever a geometry property (resolution/FOV) is changed.
        void update_local_directions();

    protected:
        static void _bind_methods();

    public:
        MirenaLidar();
        ~MirenaLidar();

        void _ros_ready() override;
        void _ros_process(double delta) override;
        
        // Getters and Setters (Declarations remain, implementation will change to call update_local_directions)
        
        // Removed set/get_refresh_rate as they were in the original list but not the body.
        // If needed, they should be implemented. Assuming they were placeholders for now.

        void set_max_range(double p_range);
        double get_max_range() const;

        void set_noise_dev(double p_dev);
        double get_noise_dev() const;

        // The setters for geometry parameters (resolution/FOV) must now call update_local_directions()
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