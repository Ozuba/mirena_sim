#ifndef MIRENACAM_H
#define MIRENACAM_H
// Godot
#include <godot_cpp/classes/camera3d.hpp>
#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/sphere_mesh.hpp>
#include <godot_cpp/classes/standard_material3d.hpp> // For sphere color
#include <godot_cpp/classes/remote_transform3d.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/classes/sub_viewport.hpp>
#include <godot_cpp/classes/sub_viewport_container.hpp>
#include <godot_cpp/classes/viewport_texture.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/file_access.hpp>
#include <godot_cpp/classes/dir_access.hpp>
#include <godot_cpp/core/error_macros.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/classes/world3d.hpp>
#include <godot_cpp/variant/rect2.hpp>
#include <godot_cpp/classes/scene_tree.hpp>
#include <godot_cpp/classes/rendering_server.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/classes/time.hpp>
#include <vector>
#include <random>

// ROS
#include "rclcpp/rclcpp.hpp"
#include "sensor_msgs/msg/image.hpp"
#include "sensor_msgs/msg/camera_info.hpp"
#include <tf2_ros/transform_broadcaster.h>
#include <tf2/LinearMath/Quaternion.h>
#include <geometry_msgs/msg/transform_stamped.hpp>

#include "node/ros_node3d.hpp"

#define AREA_THRESHOLD 400

namespace godot
{

	class MirenaCam : public RosNode3D
	{
		GDCLASS(MirenaCam, RosNode3D)
	private:
		rclcpp::Publisher<sensor_msgs::msg::Image>::SharedPtr image_publisher;	   // Image topic
		rclcpp::Publisher<sensor_msgs::msg::CameraInfo>::SharedPtr info_publisher; // Camera Info topic
		std::shared_ptr<tf2_ros::TransformBroadcaster> tf_broadcaster;		// To set camera frame
		Vector2i resolution;
		bool use_environment;
		SubViewport *viewport;
		RemoteTransform3D *camera_transform;
		Camera3D *camera;

		// Create ROS2 message
		std::unique_ptr<sensor_msgs::msg::Image> frame;
		std::unique_ptr<sensor_msgs::msg::CameraInfo> info;

		// Camera settings
		float fov;
		float near_clip;
		float far_clip;
		Camera3D::ProjectionType projection_type;
		float size_ortho;
		float h_offset;
		float v_offset;
		bool doppler_tracking;

		// Calibration and yolo training
		MeshInstance3D *find_mesh_in_node(Node3D *node);
		String datasetPath; // Path to store generated output
		bool yolo_trigger;	// Acts as trigger function

	protected:
		static void _bind_methods();
		void _cleanup();
		void _update_camera_settings();

	public:
		MirenaCam();
		~MirenaCam();

		void _ros_ready() override;
		void _ros_process(double delta) override;

		// Configuration methods
		void set_resolution(Vector2i res);
		Vector2i get_resolution() const;
		void set_use_environment(bool enable);
		bool get_use_environment() const;

		// Camera control methods
		void set_camera_position(Vector3 position);
		Vector3 get_camera_position() const;
		void set_camera_rotation(Vector3 rotation);
		Vector3 get_camera_rotation() const;

		// Training data generation
		Rect2 getScreenSize(Node3D *node_3d);
		void dump_group_bbox_to_yolo(const StringName &group_name);
		void dump_group_keypoints(const StringName &group_name);
		void set_dataset_path(String path);
		String get_dataset_path(void);

		// Utils
		String generate_uuid();

		// Camera settings methods
		void set_fov(float p_fov);
		float get_fov() const;
		void set_near_clip(float p_near);
		float get_near_clip() const;
		void set_far_clip(float p_far);
		float get_far_clip() const;
		void set_projection_type(Camera3D::ProjectionType p_type);
		Camera3D::ProjectionType get_projection_type() const;
		void set_size_ortho(float p_size);
		float get_size_ortho() const;
		void set_h_offset(float p_offset);
		float get_h_offset() const;
		void set_v_offset(float p_offset);
		float get_v_offset() const;
		void set_doppler_tracking(bool p_enable);
		bool get_doppler_tracking() const;
	};

}

#endif
