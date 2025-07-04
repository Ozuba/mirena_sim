// ros_node_3d.h
#ifndef ROS_NODE_3D_H
#define ROS_NODE_3D_H

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/engine.hpp>

#include <rclcpp/rclcpp.hpp>
#include <geometry_msgs/msg/transform_stamped.hpp>
#include <tf2_ros/transform_broadcaster.h>

#include <optional>

namespace godot
{

    class RosNode3D : public Node3D
    {
        GDCLASS(RosNode3D, Node3D)

    private:
        std::unique_ptr<tf2_ros::TransformBroadcaster> tf_broadcaster;
        bool publish_tf = true;
        double publish_rate = 10; // 10 Hz
        double elapsed_time = 0.0;
        std::optional<std::string> frame_name = std::nullopt;

        RosNode3D *find_nearest_ros_parent();

    protected:
        static void _bind_methods();

    public:
        RosNode3D();
        ~RosNode3D();

        rclcpp::Node::SharedPtr ros_node;
        rclcpp::Time current_time;
        void _ready() override;
        void _physics_process(double delta) override;


        virtual void _ros_ready();
        virtual void _ros_process(double delta);

        void set_publish_transform(bool enable);
        bool get_publish_transform() const;

        void set_publish_rate(double rate);
        double get_publish_rate() const;

        void set_frame_name(const String name);
        String get_frame_name() const;

        void publish_transform();
    };

}
#endif
