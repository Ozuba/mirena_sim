#include "mirena_ros_bridge.hpp"

using namespace mirena;
using namespace godot;

void mirena::MirenaRosBridge::_publish_full_track_curve(godot::Ref<godot::Curve3D> curve)
{
    auto msg = to_msg(curve);
    msg.header.frame_id = FIXED_FRAME_NAME;
    msg.header.stamp = _ros_node->now();
    _debugFullTrackPub->publish(msg);
}

void mirena::MirenaRosBridge::_publish_immediate_track_curve(godot::Ref<godot::Curve3D> curve)
{
    auto msg = to_msg(curve);
    msg.header.frame_id = FIXED_FRAME_NAME;
    msg.header.stamp = _ros_node->now();
    _debugImmediateTrackPub->publish(msg);
}

MirenaRosBridge::MirenaRosBridge() : _ros_node("mirena_ros_bridge"),
                                     _debugFullTrackPub(_ros_node->create_publisher<mirena_common::msg::BezierCurve>(DEBUG_FULL_TRACK_TOPIC, 10)),
                                     _debugImmediateTrackPub(_ros_node->create_publisher<mirena_common::msg::BezierCurve>(DEBUG_IMMEDIATE_TRACK_TOPIC, 10))
{
}

void MirenaRosBridge::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("publish_full_track_curve", "curve"), &MirenaRosBridge::_publish_full_track_curve);
    ClassDB::bind_method(D_METHOD("publish_immediate_track_curve", "curve"), &MirenaRosBridge::_publish_immediate_track_curve);
}