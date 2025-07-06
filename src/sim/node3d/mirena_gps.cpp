#include "mirena_gps.hpp"
#include "utility/cframe_helpers.hpp"

using namespace godot;

/////////////////////////
// Method binding
////////////////////////
void MirenaGPS::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("set_origin_latitude", "lat"), &MirenaGPS::set_origin_latitude);
    ClassDB::bind_method(D_METHOD("get_origin_latitude"), &MirenaGPS::get_origin_latitude);
    ClassDB::bind_method(D_METHOD("set_origin_longitude", "lon"), &MirenaGPS::set_origin_longitude);
    ClassDB::bind_method(D_METHOD("get_origin_longitude"), &MirenaGPS::get_origin_longitude);
    ClassDB::bind_method(D_METHOD("set_origin_altitude", "alt"), &MirenaGPS::set_origin_altitude);
    ClassDB::bind_method(D_METHOD("get_origin_altitude"), &MirenaGPS::get_origin_altitude);

    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "origin_latitude"), "set_origin_latitude", "get_origin_latitude");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "origin_longitude"), "set_origin_longitude", "get_origin_longitude");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "origin_altitude"), "set_origin_altitude", "get_origin_altitude");
}
/////////////////////////
// Constructors
////////////////////////
MirenaGPS::MirenaGPS()
{
}

MirenaGPS::~MirenaGPS()
{
}

/////////////////////////
// Getters and setters
////////////////////////

void MirenaGPS::set_origin_latitude(float lat) { origin_latitude = lat; }
float MirenaGPS::get_origin_latitude() const { return origin_latitude; }

void MirenaGPS::set_origin_longitude(float lon) { origin_longitude = lon; }
float MirenaGPS::get_origin_longitude() const { return origin_longitude; }

void MirenaGPS::set_origin_altitude(float alt) { origin_altitude = alt; }
float MirenaGPS::get_origin_altitude() const { return origin_altitude; }

/////////////////////////
// Godot/Ros runtime
////////////////////////

void MirenaGPS::_ros_ready()
{
    gps_publisher = ros_node->create_publisher<sensor_msgs::msg::NavSatFix>(GPS_PUB_TOPIC, 10);
}
void MirenaGPS::_ros_process(double delta)
{

    // Convert Godot coordinates to GPS
    Vector3 g_pos = get_global_transform().get_origin();
    Eigen::Vector3d position = godot_to_ros2(g_pos);
    double east_offset = position.x();  // East (Godot X-axis)
    double north_offset = position.y(); // North (Godot Z-axis)

    // Convert offsets to latitude and longitude
    double delta_lat = (north_offset / EARTH_RADIUS) * (180.0 / Math_PI);
    double delta_lon = (east_offset / (EARTH_RADIUS * cos(origin_latitude * Math_PI / 180.0))) * (180.0 / Math_PI);

    sensor_msgs::msg::NavSatFix gps_msg;
    gps_msg.latitude = origin_latitude + delta_lat;
    gps_msg.longitude = origin_longitude + delta_lon;
    gps_msg.altitude = origin_altitude + position.z(); // Altitude follows Godot Y-axis

    gps_publisher->publish(gps_msg);
}
