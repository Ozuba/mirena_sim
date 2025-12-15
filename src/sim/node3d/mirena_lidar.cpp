// lidar_ros.cpp
#include "mirena_lidar.hpp"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/physics_server3d.hpp>
#include <godot_cpp/classes/physics_direct_space_state3d.hpp>
#include <godot_cpp/classes/physics_ray_query_parameters3d.hpp>
#include <godot_cpp/classes/world3d.hpp>

// Standard C++ headers
#include <cmath>
#include <random> // For additive noise (now thread-safe)
#include <cstring> 

// Your existing utility header
#include "utility/cframe_helpers.hpp"

using namespace godot;

// --- Bind Methods (Unchanged) ---
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

// --- Constructor (UPDATED: Calls pre-calculation) ---
MirenaLidar::MirenaLidar() : max_range(100.0), horizontal_resolution(360), vertical_resolution(16),
                             vertical_fov(30.0), horizontal_fov(360.0), collision_mask(1)
{
    update_local_directions(); // Initial calculation of ray directions
}

MirenaLidar::~MirenaLidar()
{
    // ROS 2 shutdown is typically handled at the application level
}

// --- New Pre-calculation Logic ---
void MirenaLidar::update_local_directions()
{
    int total_rays = horizontal_resolution * vertical_resolution;
    
    if (precalculated_local_directions.size() != total_rays) {
        precalculated_local_directions.resize(total_rays);
    }
    
    // Convert to radians once here and calculate start angles
    const double PI = Math_PI;
    const double DEG_TO_RAD = PI / 180.0;
    
    const double h_angle_step_rad = horizontal_fov * DEG_TO_RAD / horizontal_resolution;
    const double v_angle_step_rad = vertical_fov * DEG_TO_RAD / vertical_resolution;
    
    // Start angle is offset by half FOV
    const double h_start_rad = -horizontal_fov * DEG_TO_RAD / 2.0;
    const double v_start_rad = -vertical_fov * DEG_TO_RAD / 2.0;

    for (int v = 0; v < vertical_resolution; ++v)
    {
        for (int h = 0; h < horizontal_resolution; ++h)
        {
            double azimuth = h_start_rad + (h_angle_step_rad * h);
            double elevation = v_start_rad + (v_angle_step_rad * v);

            // Calculate the direction vector in sensor (local) frame
            Vector3 direction = Vector3(
                                    cos(elevation) * sin(azimuth),
                                    sin(elevation),
                                    cos(elevation) * cos(azimuth))
                                    .normalized(); 

            int index = v * horizontal_resolution + h;
            precalculated_local_directions[index] = direction;
        }
    }
}


// --- Setters (UPDATED: Triggers re-calculation when geometry changes) ---

void MirenaLidar::set_max_range(double p_range) { max_range = p_range; }
double MirenaLidar::get_max_range() const { return max_range; }

void MirenaLidar::set_noise_dev(double p_dev) { noise_dev = p_dev; }
double MirenaLidar::get_noise_dev() const { return noise_dev; }

void MirenaLidar::set_horizontal_resolution(int p_resolution) { 
    if (horizontal_resolution != p_resolution) {
        horizontal_resolution = p_resolution; 
        update_local_directions(); 
    }
}
int MirenaLidar::get_horizontal_resolution() const { return horizontal_resolution; }

void MirenaLidar::set_vertical_resolution(int p_resolution) { 
    if (vertical_resolution != p_resolution) {
        vertical_resolution = p_resolution; 
        update_local_directions(); 
    }
}
int MirenaLidar::get_vertical_resolution() const { return vertical_resolution; }

void MirenaLidar::set_vertical_fov(double p_fov) { 
    if (vertical_fov != p_fov) {
        vertical_fov = p_fov; 
        update_local_directions(); 
    }
}
double MirenaLidar::get_vertical_fov() const { return vertical_fov; }

void MirenaLidar::set_horizontal_fov(double p_fov) { 
    if (horizontal_fov != p_fov) {
        horizontal_fov = p_fov; 
        update_local_directions(); 
    }
}
double MirenaLidar::get_horizontal_fov() const { return horizontal_fov; }

void MirenaLidar::set_collision_mask(uint32_t p_mask) { collision_mask = p_mask; }
uint32_t MirenaLidar::get_collision_mask() const { return collision_mask; }

// --- Ros Ready/Process (Unchanged/Simple) ---
void MirenaLidar::_ros_ready()
{
    pub = ros_node->create_publisher<sensor_msgs::msg::PointCloud2>(LIDAR_PUB_TOPIC, 10);
}

void MirenaLidar::_ros_process(double delta)
{
    scan();
}


// --- Scan Function (Optimized for CPU) ---
void MirenaLidar::scan()
{
    Ref<World3D> world = get_world_3d();
    PhysicsDirectSpaceState3D *space_state = PhysicsServer3D::get_singleton()->space_get_direct_state(world->get_space());
    
    if (!space_state) {
        // Handle error if physics space is not ready/available
        return;
    }

    // Initialize point cloud metadata
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

    // Get transforms once (outside loop)
    const Transform3D global_transform = get_global_transform();
    const Basis basis = global_transform.get_basis(); // Basis for rotation/direction transform
    const Transform3D relative_transform = global_transform.inverse(); // For converting world hit back to sensor frame
    const Vector3 origin = global_transform.get_origin();

// We paralelize the casts
#pragma omp parallel 
{
    // THREAD-LOCAL RESOURCE 1: Ray Query Parameters
    // Instantiated once per thread for efficiency and thread safety.
    thread_local Ref<PhysicsRayQueryParameters3D> ray_query;
    if (ray_query.is_null()) {
        ray_query.instantiate();
        ray_query->set_collision_mask(collision_mask);
        // Note: ray_query->set_exclude() should also be done here if needed
    }

    // THREAD-LOCAL RESOURCE 2: Random Number Generator
    // Critical: This prevents threads from serializing access to a shared static generator.
    thread_local std::random_device rd;
    // Seeding with rd() is often the bottleneck, but safer than using a static seed.
    thread_local std::mt19937 generator(rd()); 
    thread_local std::normal_distribution<double> distribution(0, noise_dev);
    
    // Pointer to the start of the data array (read-only for location, write to unique index)
    uint8_t* cloud_data_ptr = cloud->data.data();

#pragma omp for
    for (int v = 0; v < vertical_resolution; ++v)
    {
        for (int h = 0; h < horizontal_resolution; ++h)
        {
            int index_flat = v * horizontal_resolution + h;
            
            // IMPROVEMENT: Use pre-calculated local direction and transform once
            const Vector3 local_direction = precalculated_local_directions[index_flat];
            const Vector3 direction = basis.xform(local_direction); 
            const Vector3 to = origin + direction * max_range;

            // Set thread-local ray start and end points
            ray_query->set_from(origin);
            ray_query->set_to(to);

            Dictionary result = space_state->intersect_ray(ray_query);

            Vector3 final_point; 

            if (result.size() > 0)
            {
                // Generate and apply thread-local gaussian noise
                double noise_offset = distribution(generator);
                Vector3 hit_point_world = (Vector3)result["position"] + direction * noise_offset;
                
                // Transform to sensor (relative) coordinates
                final_point = relative_transform.xform(hit_point_world); 
            }
            else
            {
                // If no result, point is at max range (already transformed to world space in 'to')
                final_point = relative_transform.xform(to); 
            }
            
            // IMPROVEMENT: Direct pointer writing
            int index_byte = index_flat * cloud->point_step;
            
            Eigen::Vector3d point = godot_to_ros2(final_point);
            
            float x = static_cast<float>(point.x());
            float y = static_cast<float>(point.y());
            float z = static_cast<float>(point.z());

            // Write directly to the data array using pointer arithmetic
            float* point_ptr = reinterpret_cast<float*>(cloud_data_ptr + index_byte);
            
            point_ptr[0] = x; 
            point_ptr[1] = y; 
            point_ptr[2] = z; 
        }
    }
}

pub->publish(std::move(cloud));
}