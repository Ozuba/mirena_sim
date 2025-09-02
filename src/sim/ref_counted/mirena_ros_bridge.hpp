#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/curve3d.hpp>

#include "rclcpp/rclcpp.hpp"
#include "mirena_common/srv/get_entities.hpp"
#include "mirena_common/srv/get_car.hpp"
#include "mirena_common/srv/sim_set_pause.hpp"
#include "mirena_common/srv/sim_unpause_for.hpp"

#include "ros/ros_conversions.hpp"

#define DEBUG_FULL_TRACK_TOPIC "debug/sim/full_track_path"
#define DEBUG_CAR_STATE_PUB_TOPIC "debug/sim/car_state"

#define DEBUG_GET_ENTITIES_TOPIC "debug/sim/get_entities"
#define DEBUG_GET_CAR_TOPIC "debug/sim/get_car"

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
		rclcpp::Publisher<mirena_common::msg::BezierCurve>::SharedPtr _debugFullTrackPub;

		godot::Callable _get_entities_srv_provider;
		rclcpp::Service<mirena_common::srv::GetEntities>::SharedPtr _debugGetEntitiesSrv;

		godot::Callable _get_car_srv_provider;
		rclcpp::Service<mirena_common::srv::GetCar>::SharedPtr _debugGetCarSrv;

		godot::Callable _sim_set_pause_srv_provider;
		rclcpp::Service<mirena_common::srv::SimSetPause>::SharedPtr _simSetPauseSrv;

		godot::Callable _sim_unpause_for_srv_provider;
		rclcpp::Service<mirena_common::srv::SimUnpauseFor>::SharedPtr _simUnpauseForSrv;

		// Bindings

		void spin();

		void _publish_car_state(const godot::Vector3 &position, const godot::Vector3 &rotation, const godot::Vector3 &lin_speed, const godot::Vector3 &ang_speed, const godot::Vector3 &lin_accel, const godot::Vector3 &ang_accel);
		void _publish_full_track_curve(godot::Ref<godot::Curve3D> curve);

		void _connect_get_entities_srv(godot::Callable provider);
		void _connect_get_car_srv(godot::Callable provider);
		void _connect_sim_set_pause(godot::Callable provider);
		void _connect_sim_unpause_for(godot::Callable provider);
	
		// Inner

		void get_entities_srv(const std::shared_ptr<mirena_common::srv::GetEntities::Request> request, std::shared_ptr<mirena_common::srv::GetEntities::Response> response);
		void get_car_srv(const std::shared_ptr<mirena_common::srv::GetCar::Request> request, std::shared_ptr<mirena_common::srv::GetCar::Response> response);
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
