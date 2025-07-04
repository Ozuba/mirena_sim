// ros_node_3d.cpp
#include "ros_node3d.hpp"
#include <godot_cpp/core/class_db.hpp>
#include "utility/cframe_helpers.hpp"

namespace godot
{

    RosNode3D::RosNode3D()
    {
    }

    RosNode3D::~RosNode3D()
    {
    }

    void RosNode3D::_ready()
    {
        if (!Engine::get_singleton()->is_editor_hint())
        { // Comprobamos si estamos en el editor
            // Use object name for ROS node name
            String node_name = get_name();
            // Obligamos al nodo a usar el tiempo simulado
            rclcpp::NodeOptions options;
            options.parameter_overrides().push_back(rclcpp::Parameter("use_sim_time", true));

            ros_node = std::make_shared<rclcpp::Node>(node_name.utf8().get_data(), options);
            tf_broadcaster = std::make_unique<tf2_ros::TransformBroadcaster>(*ros_node);
            // Look for parent object

            _ros_ready();
        }
    }

    void RosNode3D::_ros_ready()
    {
    }

    void RosNode3D::_physics_process(double delta)
    {
        if (!Engine::get_singleton()->is_editor_hint())
        { // Comprobamos si estamos en el editor
          // Handle Transform publisher
            elapsed_time += delta;
            if (elapsed_time >= 1 / publish_rate)
            {
                current_time = ros_node->now();
                if (publish_tf)
                    publish_transform();
                _ros_process(delta); // call downstream processes
                elapsed_time = 0.0;
            }
            rclcpp::spin_some(ros_node);
        }
    }

    void RosNode3D::_ros_process(double delta)
    {
    }

    RosNode3D *RosNode3D::find_nearest_ros_parent()
    {
        Node *parent = get_parent();
        while (parent)
        {
            RosNode3D *ros_parent = Object::cast_to<RosNode3D>(parent);
            if (ros_parent)
            {
                return ros_parent;
            }
            parent = parent->get_parent();
        }
        return nullptr;
    }

    void RosNode3D::publish_transform()
    {
        if (!tf_broadcaster)
            return;

        geometry_msgs::msg::TransformStamped tf;

        // Get godot global trasform
        Transform3D g_tf = get_global_transform();

        RosNode3D *parent_ros_node = find_nearest_ros_parent();
        if (parent_ros_node) // if parent ros2 node get corresponding relative transform between them
        {
            std::string parent_frame = parent_ros_node->get_frame_name().utf8().get_data();
            tf.header.frame_id = parent_frame;
            // Get global transform
            g_tf = parent_ros_node->get_global_transform().affine_inverse() * g_tf; // Compute relative transform
        }
        else
        {
            tf.header.frame_id = "world";
        }
        // Esto hay que hacerlo asi XD putas strings || Ozuba ese vocabulario ... :(
        tf.child_frame_id = std::string(this->get_frame_name().utf8().get_data());

        // Convert from godot to ros2 transform (Change in coordinate frame)
        Eigen::Isometry3d r_tf = godot_to_ros2(g_tf);
        // Set translation
        tf.transform.translation.x = r_tf.translation().x();
        tf.transform.translation.y = r_tf.translation().y();
        tf.transform.translation.z = r_tf.translation().z();

        // Set rotation (as quaternion)
        Eigen::Quaterniond r_quat = godot_to_ros2(g_tf.basis.get_quaternion());
        tf.transform.rotation.w = r_quat.w();
        tf.transform.rotation.x = r_quat.x();
        tf.transform.rotation.y = r_quat.y();
        tf.transform.rotation.z = r_quat.z();

        tf.header.stamp = current_time;
        tf_broadcaster->sendTransform(tf);
    }

    void RosNode3D::_bind_methods()
    {
        ClassDB::bind_method(D_METHOD("set_publish_transform", "enable"), &RosNode3D::set_publish_transform);
        ClassDB::bind_method(D_METHOD("get_publish_transform"), &RosNode3D::get_publish_transform);

        ClassDB::bind_method(D_METHOD("set_publish_rate", "rate"), &RosNode3D::set_publish_rate);
        ClassDB::bind_method(D_METHOD("get_publish_rate"), &RosNode3D::get_publish_rate);

        ClassDB::bind_method(D_METHOD("set_frame_name", "name"), &RosNode3D::set_frame_name);
        ClassDB::bind_method(D_METHOD("get_frame_name"), &RosNode3D::get_frame_name);
       
        // Add properties
        ADD_PROPERTY(PropertyInfo(Variant::BOOL, "publish_transform"), "set_publish_transform", "get_publish_transform");
        ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "publish_rate"), "set_publish_rate", "get_publish_rate");
        ADD_PROPERTY(PropertyInfo(Variant::STRING, "frame_name"), "set_frame_name", "get_frame_name");
    }

    void RosNode3D::set_publish_transform(bool enable)
    {
        publish_tf = enable;
    }

    bool RosNode3D::get_publish_transform() const
    {
        return publish_tf;
    }

    void RosNode3D::set_publish_rate(double rate)
    {
        publish_rate = rate;
    }

    double RosNode3D::get_publish_rate() const
    {
        return publish_rate;
    }

    void RosNode3D::set_frame_name(const String name)
    {
        if (name.is_empty())
        {
            this->frame_name.reset();
        }
        else if (!name.is_valid_ascii_identifier())
        {
            return;
        }
        this->frame_name = name.utf8().get_data();
    }

    String RosNode3D::get_frame_name() const
    {
        std::string cpp_name;
        if (this->frame_name.has_value())
        {
            // If there is a frame name override
            cpp_name = this->frame_name.value();
        }
        else
        {
            // Default name
            //cpp_name = std::string(reinterpret_cast<const char *>(get_name().to_utf8_buffer().ptr()), get_name().to_utf8_buffer().size());
            cpp_name = String(this->get_name()).utf8().get_data();
        }

        return String(cpp_name.c_str());
    }

}