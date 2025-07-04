#pragma once

#include <rclcpp/rclcpp.hpp>

#include <godot_cpp/classes/ref_counted.hpp>

#include "utility/ros_conversions.hpp"

#define DEBUG_FULL_TRACK_TOPIC "debug/sim/full_track_path"
#define DEBUG_IMMEDIATE_TRACK_TOPIC "debug/sim/immediate_track_path"

#define FIXED_FRAME_NAME "world"

namespace mirena 
{
	// Refcounted object used as a binding for publishing and subscribing to topics, as well as hosting and requesting services
	class MirenaRosBridge: public RefCounted 
	{
		GDCLASS(MirenaRosBridge, RefCounted);

	private:
		rclcpp::Node _ros_node;
		rclcpp::Publisher<mirena_common::msg::BezierCurve>::SharedPtr _debugFullTrackPub; // Line strip
		rclcpp::Publisher<mirena_common::msg::BezierCurve>::SharedPtr _debugImmediateTrackPub; // Line strip


		void _publish_full_track_curve(godot::Curve3D curve){_debugFullTrackPub->publish(mirena::to_msg(curve));}
		void _publish_immediate_track_curve(godot::Curve3D curve){_debugFullTrackPub->publish(mirena::to_msg(curve));}

	public:
		// Constructors
		MirenaRosBridge();
		~MirenaRosBridge() {};
	
	
	protected:
		static void _bind_methods();

	};

}
