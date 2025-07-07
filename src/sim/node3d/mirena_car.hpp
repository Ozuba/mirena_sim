#ifndef MIRENACAR_H
#define MIRENACAR_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

// ROS
#include "rclcpp/rclcpp.hpp"
#include "mirena_common/msg/car_input.hpp"
#include "mirena_common/msg/wheel_speeds.hpp"
#include "mirena_common/msg/car.hpp"

#include"sim/node3d/ros_node3d.hpp"

#define WSS_PUB_TOPIC "sensors/wss"
#define CAR_INPUT_SUB_TOPIC "control/car_input"

#define FIXED_FRAME_NAME "world"

namespace godot
{

	class MirenaCarBase : public RosNode3D
	{
		GDCLASS(MirenaCarBase, RosNode3D);

	private:
		// ROS subscriber and callback
		rclcpp::Subscription<mirena_common::msg::CarInput>::SharedPtr rosSub;

		// WSS Weel speed sensor publisher
		rclcpp::Publisher<mirena_common::msg::WheelSpeeds>::SharedPtr wheelSpeedPub;

		// Internal Car Inputs
		float gas;
		float brake;
		float steer_angle;

		// Internal Car Outputs
		float w_rl, w_rr, w_fl, w_fr; // Wheel speeds rad/s

	protected:
		static void _bind_methods();

	public:
		// Constructors
		MirenaCarBase();
		~MirenaCarBase();
		// Getters and setters
		void set_gas(float _gas);
		float get_gas();
		void set_brake(float _brake);
		float get_brake();
		void set_steer_angle(float _steer_angle);
		float get_steer_angle();

		void set_wheels_speed(float rl, float rr, float fl, float fr);

		// Godot runtime
		void _ros_ready() override;
		void _ros_process(double delta) override;
		// ROS
		void topic_callback(const mirena_common::msg::CarInput::SharedPtr msg);
	};

}

#endif
