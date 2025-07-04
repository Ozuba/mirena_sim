#include "mirena_common/msg/bezier_curve.hpp"

#include "godot_cpp/classes/curve3d.hpp"

namespace mirena {
    mirena_common::msg::BezierCurve to_msg(godot::Curve3D native);

    geometry_msgs::msg::Point to_msg(godot::Vector3 native);
}