#pragma once

// GODOT
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include "node/ros_node3d.hpp"

// ROS
#include "rclcpp/rclcpp.hpp"
#include <sensor_msgs/msg/nav_sat_fix.hpp>

#define GPS_PUB_TOPIC "sensors/gps"

namespace godot
{

    class MirenaGPS : public RosNode3D
    {
        GDCLASS(MirenaGPS, RosNode3D)

    private:
        // Publishers
        rclcpp::Publisher<sensor_msgs::msg::NavSatFix>::SharedPtr gps_publisher;
        double origin_latitude = 37.7749; // Default: San Francisco
        double origin_longitude = -122.4194;
        double origin_altitude = 0.0;
        // Constant
        const double EARTH_RADIUS = 6378137.0; // WGS84 major axis radius in meters
    protected:
        static void _bind_methods();

    public:
        // Constructors
        MirenaGPS();
        ~MirenaGPS();
        // Godot runtime
        void _ros_ready() override;
        void _ros_process(double delta) override;

        // Getters and setters
        void set_origin_latitude(float lat);
        float get_origin_latitude()const;;

        void set_origin_longitude(float lon);
        float get_origin_longitude()const;;

        void set_origin_altitude(float alt);
        float get_origin_altitude()const;;
    };

}
