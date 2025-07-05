#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/classes/curve3d.hpp>

#include "utility/ros_conversions.hpp"
#include "ros/active_ros_node.hpp"

#define DEBUG_FULL_TRACK_TOPIC "debug/sim/full_track_path"
#define DEBUG_IMMEDIATE_TRACK_TOPIC "debug/sim/immediate_track_path"

#define FIXED_FRAME_NAME "world"

namespace mirena 
{
	// Refcounted object used as a binding for publishing and subscribing to topics, as well as hosting and requesting services
	class MirenaRosBridge: public godot::RefCounted 
	{
		GDCLASS(MirenaRosBridge, godot::RefCounted);

	private:
		ActiveRosNode _ros_node;
		rclcpp::Publisher<mirena_common::msg::BezierCurve>::SharedPtr _debugFullTrackPub; // Line strip
		rclcpp::Publisher<mirena_common::msg::BezierCurve>::SharedPtr _debugImmediateTrackPub; // Line strip


		void _publish_full_track_curve(godot::Ref<godot::Curve3D> curve){_debugFullTrackPub->publish(mirena::to_msg(curve));}
		void _publish_immediate_track_curve(godot::Ref<godot::Curve3D> curve){_debugFullTrackPub->publish(mirena::to_msg(curve));}

	public:
		// Constructors
		MirenaRosBridge();
		~MirenaRosBridge() {};
	
	
	protected:
	static void _bind_methods();

	};

}
