#include "ros_conversions.hpp"

mirena_common::msg::BezierCurve mirena::to_msg(godot::Curve3D curve)
{
    mirena_common::msg::BezierCurve msg;
    int number_of_points = curve.get_point_count();
    msg.points.reserve(number_of_points);

    for(int point_index = 0; point_index < number_of_points; point_index++){
        mirena_common::msg::BezierCurvePoint point_msg;
        point_msg.set__point(to_msg(curve.get_point_position(point_index)));
        point_msg.set__in_control_point(to_msg(curve.get_point_in(point_index)));
        point_msg.set__out_control_point(to_msg(curve.get_point_out(point_index)));
        msg.points.push_back(point_msg);
    }

    msg.is_closed = curve.is_closed();

    return msg;
}

geometry_msgs::msg::Point mirena::to_msg(godot::Vector3 native)
{
    geometry_msgs::msg::Point msg;
    msg.x = native.x;
    msg.y = native.y;
    msg.z = native.z;
    return msg;
}
