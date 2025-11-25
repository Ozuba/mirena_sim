#include "mirena_ros_bridge.hpp"

using std::placeholders::_1;
using std::placeholders::_2;

using namespace mirena;
using namespace godot;

void mirena::MirenaRosBridge::spin(){
    rclcpp::spin_some(_ros_node);
}

void mirena::MirenaRosBridge::_publish_car_state(const Vector3 &position, const Vector3 &rotation, const Vector3 &lin_speed, const Vector3 &ang_speed, const Vector3 &lin_accel, const Vector3 &ang_accel)
{
    mirena_common::msg::Car msg;
    
    msg.header.frame_id =  FIXED_FRAME_NAME;
    msg.header.stamp = _ros_node->now();

    //Perform coordinate frame conversions
    auto pos = to_msg(position);
    auto rot = to_msg(rotation);
    auto l_speed = to_msg(lin_speed);
    auto a_speed = to_msg(ang_speed);

    // Fill state vector 
    msg.x = pos.x;
    msg.y = pos.y;
    msg.psi = rot.z;
    msg.u = l_speed.x;
    msg.v = l_speed.y;
    msg.omega = a_speed.z;
   
    _debugCarStatePub->publish(msg);
}

void mirena::MirenaRosBridge::_publish_full_centerline_curve(godot::Ref<godot::Curve3D> curve)
{
    auto msg = to_msg(curve);
    msg.header.frame_id = FIXED_FRAME_NAME;
    msg.header.stamp = _ros_node->now();
    _debugFullCenterlinePub->publish(msg);
}

void mirena::MirenaRosBridge::_publish_slam_entities(Array entities)
{
    mirena_common::msg::EntityList msg;
    for(int i = 0; i < entities.size(); i++){
        Variant item = entities.get(i);
        if(item.get_type() != Variant::VECTOR3) {continue;}
        Vector3 position = (Vector3)item;
        mirena_common::msg::Entity ros_entity;
        ros_entity.position = to_msg(position);
        msg.entities.push_back(ros_entity);
    }
    msg.header.frame_id = FIXED_FRAME_NAME;
    msg.header.stamp = _ros_node->now();
    _debugSlamEntitiesPub->publish(msg);
}

void mirena::MirenaRosBridge::_publish_perception_entities(Array entities)
{
    mirena_common::msg::EntityList msg;
    for(int i = 0; i < entities.size(); i++){
        Variant item = entities.get(i);
        if(item.get_type() != Variant::VECTOR3) {continue;}
        Vector3 position = (Vector3)item;
        mirena_common::msg::Entity ros_entity;
        ros_entity.position = to_msg(position);
        msg.entities.push_back(ros_entity);
    }
    msg.header.frame_id = CAR_FRAME_NAME;
    msg.header.stamp = _ros_node->now();
    _debugPerceptionEntitiesPub->publish(msg);
}


void mirena::MirenaRosBridge::_publish_inferred_control(double gas, double steer){
    mirena_common::msg::CarControl msg;
    msg.gas = gas;
    msg.steer_angle = steer;
    msg.header.frame_id = FIXED_FRAME_NAME;
    msg.header.stamp = _ros_node->now();
    _debugInferredControlPub->publish(msg); 
}

void mirena::MirenaRosBridge::_publish_track(Array gates, bool is_closed){

    mirena_common::msg::Track msg;

    if(gates.size() <= 0) return;
    //Fill gates
    for (int i = 0; i < gates.size(); i++)
    {
        //Cover array
        Variant item = gates.get(i);
        if(item.get_type() != Variant::VECTOR3) {continue;}
        Vector3 gate_in = (Vector3)item;
        mirena_common::msg::Gate gate;
        gate.x = gate_in.x;
        gate.y = gate_in.y;
        gate.psi = gate_in.z;
        msg.gates.push_back(gate);
    }
    //IsClosed
    msg.is_closed = is_closed;

    //Fill header
    msg.header.frame_id = FIXED_FRAME_NAME;
    msg.header.stamp = _ros_node->now();
    _debugTrackPub->publish(msg); 
}


void mirena::MirenaRosBridge::_connect_sim_set_pause(godot::Callable provider)
{
    _sim_set_pause_srv_provider = provider;
}

void mirena::MirenaRosBridge::_connect_sim_unpause_for(godot::Callable provider)
{
    _sim_unpause_for_srv_provider = provider;
}

void mirena::MirenaRosBridge::sim_set_pause_srv(const std::shared_ptr<mirena_common::srv::SimSetPause::Request> request, std::shared_ptr<mirena_common::srv::SimSetPause::Response> response)
{
    godot::Variant result_var = _sim_set_pause_srv_provider.call(mirena::to_request(request));

    if(result_var.get_type() != Variant::OBJECT){
        godot::UtilityFunctions::print("Error Occured during call to ", _sim_set_pause_srv_provider.get_method(), " on ros request resolution");
        return;
    }
}

void mirena::MirenaRosBridge::sim_unpause_for_srv(const std::shared_ptr<mirena_common::srv::SimUnpauseFor::Request> request, std::shared_ptr<mirena_common::srv::SimUnpauseFor::Response> response)
{
    godot::Variant result_var = _sim_unpause_for_srv_provider.call(mirena::to_request(request));

    if(result_var.get_type() != Variant::OBJECT){
        godot::UtilityFunctions::print("Error Occured during call to ", _sim_unpause_for_srv_provider.get_method(), " on ros request resolution");
        return;
    }
}

MirenaRosBridge::MirenaRosBridge() : _ros_node(rclcpp::Node::make_shared("mirena_ros_bridge")),
                                     _debugCarStatePub(_ros_node->create_publisher<mirena_common::msg::Car>(DEBUG_CAR_STATE_PUB_TOPIC, 10)),
                                     _debugFullCenterlinePub(_ros_node->create_publisher<mirena_common::msg::BezierCurve>(DEBUG_FULL_CENTERLINE_PUB_TOPIC, 10)),
                                     _debugSlamEntitiesPub(_ros_node->create_publisher<mirena_common::msg::EntityList>(DEBUG_SLAM_ENTITIES_PUB_TOPIC, 10)),
                                     _debugInferredControlPub(_ros_node->create_publisher<mirena_common::msg::CarControl>(DEBUG_INFERRED_CONTROL_PUB_TOPIC, 10)),
                                     _debugPerceptionEntitiesPub(_ros_node->create_publisher<mirena_common::msg::EntityList>(DEBUG_PERCEPTION_ENTITIES_PUB_TOPIC, 10)),
                                     _debugTrackPub(_ros_node->create_publisher<mirena_common::msg::Track>(DEBUG_TRACK_TOPIC, 10)),
                                     _simSetPauseSrv(_ros_node->create_service<mirena_common::srv::SimSetPause>(SIM_SET_PAUSE_SRV_TOPIC, std::bind(&MirenaRosBridge::sim_set_pause_srv, this, _1, _2))),
                                     _simUnpauseForSrv(_ros_node->create_service<mirena_common::srv::SimUnpauseFor>(SIM_UNPAUSE_FOR_SRV_TOPIC, std::bind(&MirenaRosBridge::sim_unpause_for_srv, this, _1, _2)))
{
}

void MirenaRosBridge::_bind_methods()
{

    ClassDB::bind_method(D_METHOD("spin"), &MirenaRosBridge::spin);

    ClassDB::bind_method(D_METHOD("publish_car_state", "pos", "rot", "lin_speed", "ang_speed", "lin_accel", "ang_accel"), &MirenaRosBridge::_publish_car_state);
    ClassDB::bind_method(D_METHOD("publish_full_track_curve", "curve"), &MirenaRosBridge::_publish_full_centerline_curve);
    ClassDB::bind_method(D_METHOD("publish_slam_entities", "entity_array"), &MirenaRosBridge::_publish_slam_entities);
    ClassDB::bind_method(D_METHOD("publish_inferred_control", "gas", "steer"), &MirenaRosBridge::_publish_inferred_control);
    ClassDB::bind_method(D_METHOD("publish_perception_entities", "entity_array"), &MirenaRosBridge::_publish_perception_entities);
    ClassDB::bind_method(D_METHOD("publish_track", "gates","is_closed"), &MirenaRosBridge::_publish_track);

    ClassDB::bind_method(D_METHOD("connect_sim_set_pause", "provider"), &MirenaRosBridge::_connect_sim_set_pause);
    ClassDB::bind_method(D_METHOD("connect_sim_unpause_for", "provider"), &MirenaRosBridge::_connect_sim_unpause_for);
}