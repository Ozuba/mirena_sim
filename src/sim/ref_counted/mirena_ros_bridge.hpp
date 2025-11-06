#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/curve3d.hpp>

#include "rclcpp/rclcpp.hpp"
#include "mirena_common/srv/sim_set_pause.hpp"
#include "mirena_common/srv/sim_unpause_for.hpp"
#include "mirena_common/msg/entity_list.hpp"
#include "mirena_common/msg/car_control.hpp"

#include "ros/ros_conversions.hpp"

#define DEBUG_FULL_CENTERLINE_PUB_TOPIC "debug/sim/full_centerline_path"
#define DEBUG_CAR_STATE_PUB_TOPIC "debug/sim/car_state"
#define DEBUG_SLAM_ENTITIES_PUB_TOPIC "debug/sim/slam_entities"
#define DEBUG_INFERRED_CONTROL_PUB_TOPIC "debug/sim/inferred_control"
#define DEBUG_PERCEPTION_ENTITIES_PUB_TOPIC "debug/sim/perception_entities"

#define SIM_SET_PAUSE_SRV_TOPIC "sim/set_pause"
#define SIM_UNPAUSE_FOR_SRV_TOPIC "sim/unpause_for"

#define FIXED_FRAME_NAME "world"

namespace mirena
{
	// Refcounted object used as a binding for publishing and subscribing to topics, as well as hosting and requesting services
	class MirenaRosBridge : public godot::RefCounted
	{
		GDCLASS(MirenaRosBridge, godot::RefCounted);

	private:
		rclcpp::Node::SharedPtr _ros_node;
		
		rclcpp::Publisher<mirena_common::msg::Car>::SharedPtr _debugCarStatePub;
		rclcpp::Publisher<mirena_common::msg::BezierCurve>::SharedPtr _debugFullCenterlinePub;
		rclcpp::Publisher<mirena_common::msg::EntityList>::SharedPtr _debugSlamEntitiesPub;
		rclcpp::Publisher<mirena_common::msg::CarControl>::SharedPtr _debugInferredControlPub;
		rclcpp::Publisher<mirena_common::msg::EntityList>::SharedPtr _debugPerceptionEntitiesPub;

		godot::Callable _sim_set_pause_srv_provider;
		rclcpp::Service<mirena_common::srv::SimSetPause>::SharedPtr _simSetPauseSrv;

		godot::Callable _sim_unpause_for_srv_provider;
		rclcpp::Service<mirena_common::srv::SimUnpauseFor>::SharedPtr _simUnpauseForSrv;

		// Bindings

		void spin();

		void _publish_car_state(const godot::Vector3 &position, const godot::Vector3 &rotation, const godot::Vector3 &lin_speed, const godot::Vector3 &ang_speed, const godot::Vector3 &lin_accel, const godot::Vector3 &ang_accel);
		void _publish_full_centerline_curve(godot::Ref<godot::Curve3D> curve);
		void _publish_slam_entities(godot::Array entities);
		void _publish_inferred_control(double gas, double steer);
		void _publish_perception_entities(godot::Array entities);

		void _connect_sim_set_pause(godot::Callable provider);
		void _connect_sim_unpause_for(godot::Callable provider);
	
		// Inner

		void sim_set_pause_srv(const std::shared_ptr<mirena_common::srv::SimSetPause::Request> request, std::shared_ptr<mirena_common::srv::SimSetPause::Response> response);
		void sim_unpause_for_srv(const std::shared_ptr<mirena_common::srv::SimUnpauseFor::Request> request, std::shared_ptr<mirena_common::srv::SimUnpauseFor::Response> response);


	public:
		// Constructors
		MirenaRosBridge();
		~MirenaRosBridge() {};

	protected:
		static void _bind_methods();
	};

}
