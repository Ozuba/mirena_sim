
// lidar_ros.cpp
#include "mirena_lidar.hpp"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/physics_server3d.hpp>

#include <godot_cpp/classes/physics_direct_space_state3d.hpp>
#include <godot_cpp/classes/physics_ray_query_parameters3d.hpp>
#include <godot_cpp/classes/world3d.hpp>
#include <cmath>
#include <random> //For additive noise
#include "utility/cframe_helpers.hpp"

using namespace godot;

void MirenaLidar::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("set_max_range", "range"), &MirenaLidar::set_max_range);
    ClassDB::bind_method(D_METHOD("get_max_range"), &MirenaLidar::get_max_range);
    ClassDB::bind_method(D_METHOD("set_noise_dev", "deviation"), &MirenaLidar::set_noise_dev);
    ClassDB::bind_method(D_METHOD("get_noise_dev"), &MirenaLidar::get_noise_dev);
    ClassDB::bind_method(D_METHOD("set_horizontal_resolution", "resolution"), &MirenaLidar::set_horizontal_resolution);
    ClassDB::bind_method(D_METHOD("get_horizontal_resolution"), &MirenaLidar::get_horizontal_resolution);
    ClassDB::bind_method(D_METHOD("set_vertical_resolution", "resolution"), &MirenaLidar::set_vertical_resolution);
    ClassDB::bind_method(D_METHOD("get_vertical_resolution"), &MirenaLidar::get_vertical_resolution);
    ClassDB::bind_method(D_METHOD("set_vertical_fov", "fov"), &MirenaLidar::set_vertical_fov);
    ClassDB::bind_method(D_METHOD("get_vertical_fov"), &MirenaLidar::get_vertical_fov);
    ClassDB::bind_method(D_METHOD("set_horizontal_fov", "fov"), &MirenaLidar::set_horizontal_fov);
    ClassDB::bind_method(D_METHOD("get_horizontal_fov"), &MirenaLidar::get_horizontal_fov);
    ClassDB::bind_method(D_METHOD("set_collision_mask", "mask"), &MirenaLidar::set_collision_mask);
    ClassDB::bind_method(D_METHOD("get_collision_mask"), &MirenaLidar::get_collision_mask);
    ClassDB::bind_method(D_METHOD("scan"), &MirenaLidar::scan);

    // Add properties
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "max_range"), "set_max_range", "get_max_range");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "noise_dev"), "set_noise_dev", "get_noise_dev");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "horizontal_resolution"), "set_horizontal_resolution", "get_horizontal_resolution");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "vertical_resolution"), "set_vertical_resolution", "get_vertical_resolution");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "vertical_fov"), "set_vertical_fov", "get_vertical_fov");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "horizontal_fov"), "set_horizontal_fov", "get_horizontal_fov");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "collision_mask"), "set_collision_mask", "get_collision_mask");
}

MirenaLidar::MirenaLidar() : max_range(100.0), horizontal_resolution(360), vertical_resolution(16),
                             vertical_fov(30.0), horizontal_fov(360.0), collision_mask(1)
{
}

MirenaLidar::~MirenaLidar()
{
    // ROS 2 shutdown is typically handled at the application level
}

void MirenaLidar::set_max_range(double p_range) { max_range = p_range; }
double MirenaLidar::get_max_range() const { return max_range; }

void MirenaLidar::set_noise_dev(double p_dev) { noise_dev = p_dev; }
double MirenaLidar::get_noise_dev() const { return noise_dev; }

void MirenaLidar::set_horizontal_resolution(int p_resolution) { horizontal_resolution = p_resolution; }
int MirenaLidar::get_horizontal_resolution() const { return horizontal_resolution; }

void MirenaLidar::set_vertical_resolution(int p_resolution) { vertical_resolution = p_resolution; }
int MirenaLidar::get_vertical_resolution() const { return vertical_resolution; }

void MirenaLidar::set_vertical_fov(double p_fov) { vertical_fov = p_fov; }
double MirenaLidar::get_vertical_fov() const { return vertical_fov; }

void MirenaLidar::set_horizontal_fov(double p_fov) { horizontal_fov = p_fov; }
double MirenaLidar::get_horizontal_fov() const { return horizontal_fov; }

void MirenaLidar::set_collision_mask(uint32_t p_mask) { collision_mask = p_mask; }
uint32_t MirenaLidar::get_collision_mask() const { return collision_mask; }

void MirenaLidar::_ros_ready()
{
    pub = ros_node->create_publisher<sensor_msgs::msg::PointCloud2>(LIDAR_PUB_TOPIC, 10);
}

void MirenaLidar::scan()
{
    Ref<World3D> world = get_world_3d();
    PhysicsDirectSpaceState3D *space_state = PhysicsServer3D::get_singleton()->space_get_direct_state(world->get_space());

    auto cloud = std::make_unique<sensor_msgs::msg::PointCloud2>();
    cloud->header.stamp = ros_node->now();
    cloud->header.frame_id = ros_node->get_name();
    cloud->height = vertical_resolution;
    cloud->width = horizontal_resolution;
    cloud->fields.resize(3);

    cloud->fields[0].name = "x";
    cloud->fields[0].offset = 0;
    cloud->fields[0].datatype = sensor_msgs::msg::PointField::FLOAT32;
    cloud->fields[0].count = 1;

    cloud->fields[1].name = "y";
    cloud->fields[1].offset = 4;
    cloud->fields[1].datatype = sensor_msgs::msg::PointField::FLOAT32;
    cloud->fields[1].count = 1;

    cloud->fields[2].name = "z";
    cloud->fields[2].offset = 8;
    cloud->fields[2].datatype = sensor_msgs::msg::PointField::FLOAT32;
    cloud->fields[2].count = 1;

    cloud->point_step = 12; // Memory offset 3*4bytes
    cloud->row_step = cloud->point_step * cloud->width;
    cloud->data.resize(cloud->row_step * cloud->height);
    cloud->is_dense = true;

    Transform3D global_transform = get_global_transform();
    Transform3D relative_transform = global_transform.inverse(); // Get the inverse transform to bring all the points relative to lidar
    Vector3 origin = global_transform.get_origin();

    double h_angle_step = horizontal_fov / horizontal_resolution;
    double v_angle_step = vertical_fov / vertical_resolution;

// We paralelize the casts
#pragma omp parallel 
{

    Ref<PhysicsRayQueryParameters3D> ray_query;
    ray_query.instantiate();
    ray_query->set_collision_mask(collision_mask);

#pragma omp for
    for (int v = 0; v < vertical_resolution; ++v)
    {
        for (int h = 0; h < horizontal_resolution; ++h)
        {
            float azimuth = (h_angle_step * h - horizontal_fov / 2.0) * Math_PI / 180.0;
            float elevation = (v_angle_step * v - vertical_fov / 2.0) * Math_PI / 180.0;

            Vector3 direction = Vector3(
                                    cos(elevation) * sin(azimuth),
                                    sin(elevation),
                                    cos(elevation) * cos(azimuth))
                                    .normalized();

            direction = global_transform.basis.xform(direction);
            Vector3 to = origin + direction * max_range;

            ray_query->set_from(origin);
            ray_query->set_to(to);

            Dictionary result = space_state->intersect_ray(ray_query);

            Vector3 hit_point; // For result

            if (result.size() > 0)
            {
                // Generate gaussian noise
                static std::random_device rd;
                static std::mt19937 generator(rd());
                std::normal_distribution<double> distribution(0, noise_dev);
                // Apply the gaussian noise to result measure
                hit_point = (Vector3)result["position"] + direction * distribution(generator);
                hit_point = relative_transform.xform(hit_point); // Get the point with relative coordinate to lidar source
            }
            else
            {
                hit_point = relative_transform.xform(to); // If no result just outputs the maximun range
            }

            int index = (v * horizontal_resolution + h) * cloud->point_step;
            Eigen::Vector3d point = godot_to_ros2(hit_point);
            float x = static_cast<float>(point.x());
            float y = static_cast<float>(point.y());
            float z = static_cast<float>(point.z());

            // Directly write to cloud->data using pointer manipulation
            memcpy(&cloud->data[index + 0], &x, sizeof(float));
            memcpy(&cloud->data[index + 4], &y, sizeof(float));
            memcpy(&cloud->data[index + 8], &z, sizeof(float));
        }
    }
}

pub->publish(std::move(cloud));
// UtilityFunctions::print("3D LIDAR scan published:");
}

void MirenaLidar::_ros_process(double delta)
{
    scan();
}
