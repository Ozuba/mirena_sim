#ifndef MIRENACAR_H
#define MIRENACAR_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/vector2.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

// ROS
#include "rclcpp/rclcpp.hpp"
#include "mirena_common/msg/car_control.hpp"
#include "mirena_common/msg/wheel_speeds.hpp"
#include "mirena_common/msg/car.hpp"

#include"sim/node3d/ros_node3d.hpp"

#define WSS_PUB_TOPIC "sensors/wss"
#define CAR_CONTROL_SUB_TOPIC "control/car_control"

#define FIXED_FRAME_NAME "world"

namespace godot
{

	class MirenaCarBase : public RosNode3D
	{
		GDCLASS(MirenaCarBase, RosNode3D);

	private:
		// ROS subscriber and callback
		rclcpp::Subscription<mirena_common::msg::CarControl>::SharedPtr rosSub;

		// WSS Weel speed sensor publisher
		rclcpp::Publisher<mirena_common::msg::WheelSpeeds>::SharedPtr wheelSpeedPub;

		bool has_control_buffered;
		float gas_buffer;
		float steer_angle_buffer;

		// Internal Car Outputs
		float w_rl, w_rr, w_fl, w_fr; // Wheel speeds rad/s

	protected:
		static void _bind_methods();

	public:
		MirenaCarBase();
		// Getters and setters
		bool has_control_input();
		Vector2 consume_control_input();

		void set_wheels_speed(float rl, float rr, float fl, float fr);

		// Godot runtime
		void _ros_ready() override;
		void _ros_process(double delta) override;
		// ROS
		void topic_callback(const mirena_common::msg::CarControl::SharedPtr msg);
	};

}

#endif
