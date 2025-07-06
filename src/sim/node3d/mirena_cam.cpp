#include "mirena_cam.hpp"

using namespace godot;

void MirenaCam::_bind_methods()
{

    ClassDB::bind_method(D_METHOD("set_resolution", "resolution"), &MirenaCam::set_resolution);
    ClassDB::bind_method(D_METHOD("get_resolution"), &MirenaCam::get_resolution);
    ClassDB::bind_method(D_METHOD("set_use_environment", "enable"), &MirenaCam::set_use_environment);
    ClassDB::bind_method(D_METHOD("get_use_environment"), &MirenaCam::get_use_environment);
    ClassDB::bind_method(D_METHOD("set_camera_position", "position"), &MirenaCam::set_camera_position);
    ClassDB::bind_method(D_METHOD("get_camera_position"), &MirenaCam::get_camera_position);
    ClassDB::bind_method(D_METHOD("set_camera_rotation", "rotation"), &MirenaCam::set_camera_rotation);
    ClassDB::bind_method(D_METHOD("get_camera_rotation"), &MirenaCam::get_camera_rotation);

    // Yolo dumper function
    ClassDB::bind_method(D_METHOD("dump_group_bbox_to_yolo", "groupname"), &MirenaCam::dump_group_bbox_to_yolo);
    ClassDB::bind_method(D_METHOD("dump_group_keypoints", "groupname"), &MirenaCam::dump_group_keypoints);

    ClassDB::bind_method(D_METHOD("set_dataset_path", "path"), &MirenaCam::set_dataset_path);
    ClassDB::bind_method(D_METHOD("get_dataset_path"), &MirenaCam::get_dataset_path);

    // Camera settings bindings
    ClassDB::bind_method(D_METHOD("set_fov", "fov"), &MirenaCam::set_fov);
    ClassDB::bind_method(D_METHOD("get_fov"), &MirenaCam::get_fov);
    ClassDB::bind_method(D_METHOD("set_near_clip", "near"), &MirenaCam::set_near_clip);
    ClassDB::bind_method(D_METHOD("get_near_clip"), &MirenaCam::get_near_clip);
    ClassDB::bind_method(D_METHOD("set_far_clip", "far"), &MirenaCam::set_far_clip);
    ClassDB::bind_method(D_METHOD("get_far_clip"), &MirenaCam::get_far_clip);
    ClassDB::bind_method(D_METHOD("set_projection_type", "type"), &MirenaCam::set_projection_type);
    ClassDB::bind_method(D_METHOD("get_projection_type"), &MirenaCam::get_projection_type);
    ClassDB::bind_method(D_METHOD("set_size_ortho", "size"), &MirenaCam::set_size_ortho);
    ClassDB::bind_method(D_METHOD("get_size_ortho"), &MirenaCam::get_size_ortho);
    ClassDB::bind_method(D_METHOD("set_h_offset", "offset"), &MirenaCam::set_h_offset);
    ClassDB::bind_method(D_METHOD("get_h_offset"), &MirenaCam::get_h_offset);
    ClassDB::bind_method(D_METHOD("set_v_offset", "offset"), &MirenaCam::set_v_offset);
    ClassDB::bind_method(D_METHOD("get_v_offset"), &MirenaCam::get_v_offset);
    ClassDB::bind_method(D_METHOD("set_doppler_tracking", "enable"), &MirenaCam::set_doppler_tracking);
    ClassDB::bind_method(D_METHOD("get_doppler_tracking"), &MirenaCam::get_doppler_tracking);

    // Camera settings
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "fov", PROPERTY_HINT_RANGE, "1,179,0.1"), "set_fov", "get_fov");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "near_clip", PROPERTY_HINT_RANGE, "0.001,10,0.001"), "set_near_clip", "get_near_clip");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "far_clip", PROPERTY_HINT_RANGE, "0.1,10000,0.1"), "set_far_clip", "get_far_clip");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "projection_type", PROPERTY_HINT_ENUM, "Perspective,Orthogonal"), "set_projection_type", "get_projection_type");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "size_ortho", PROPERTY_HINT_RANGE, "0.1,1000,0.1"), "set_size_ortho", "get_size_ortho");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "h_offset", PROPERTY_HINT_RANGE, "-10,10,0.01"), "set_h_offset", "get_h_offset");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "v_offset", PROPERTY_HINT_RANGE, "-10,10,0.01"), "set_v_offset", "get_v_offset");
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "doppler_tracking"), "set_doppler_tracking", "get_doppler_tracking");
    // NODE
    ADD_PROPERTY(PropertyInfo(Variant::VECTOR2I, "resolution"), "set_resolution", "get_resolution");
    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "use_environment"), "set_use_environment", "get_use_environment");

    // Yolo trainer path
    ADD_PROPERTY(PropertyInfo(Variant::STRING, "Dataset Path", PROPERTY_HINT_GLOBAL_DIR), "set_dataset_path", "get_dataset_path");
}
MirenaCam::MirenaCam() : resolution(Vector2i(640, 480)),
                         use_environment(true),
                         viewport(nullptr),
                         camera(nullptr), fov(75.0),
                         near_clip(0.05),
                         far_clip(1000.0),
                         projection_type(Camera3D::PROJECTION_PERSPECTIVE),
                         size_ortho(10.0),
                         h_offset(0.0),
                         v_offset(0.0),
                         doppler_tracking(false),
                         datasetPath(" ")
{
}

MirenaCam::~MirenaCam()
{
    // _cleanup();
}

void MirenaCam::_cleanup()
{
    if (camera_transform)
    {
        memdelete(camera_transform);
        camera_transform = nullptr;
    }
    if (camera)
    {
        memdelete(camera);
        camera = nullptr;
    }
    if (viewport)
    {
        memdelete(viewport);
        viewport = nullptr;
    }
}

void MirenaCam::_ros_ready()
{

    // Create publishers
    image_publisher = ros_node->create_publisher<sensor_msgs::msg::Image>(std::string(ros_node->get_name()) + "/image", 10);
    info_publisher = ros_node->create_publisher<sensor_msgs::msg::CameraInfo>(std::string(ros_node->get_name()) + "/camera_info", 10);
    tf_broadcaster = std::make_shared<tf2_ros::TransformBroadcaster>(*ros_node);
    // Create viewport
    viewport = memnew(SubViewport);
    viewport->set_size(resolution);
    viewport->set_use_own_world_3d(false);
    viewport->set_clear_mode(SubViewport::CLEAR_MODE_ALWAYS);
    viewport->set_update_mode(SubViewport::UPDATE_ALWAYS);

    // Create camera
    camera = memnew(Camera3D);
    // Create transform
    camera_transform = memnew(RemoteTransform3D);
    add_child(camera_transform); // Add to inherit RosNode3D transform
    _update_camera_settings();
    viewport->add_child(camera);

    // If using environment, copy it from the main viewport
    if (use_environment)
    {
        Viewport *main_viewport = get_viewport();
        if (main_viewport && main_viewport->get_world_3d().is_valid())
        {
            viewport->set_world_3d(main_viewport->get_world_3d());
        }
    }

    add_child(viewport);
    camera_transform->set_remote_node(camera->get_path()); // Make camera follow
}

void MirenaCam::_ros_process(double delta)
{

    // Create ROS2 messages
    sensor_msgs::msg::Image frame;
    geometry_msgs::msg::TransformStamped transformStamped;
    sensor_msgs::msg::CameraInfo info;

    // Publish the viewport rendered image
    Ref<Image> img = viewport->get_texture()->get_image();
    if (img.is_null())
        return;

    frame.header.stamp = ros_node->now();
    frame.header.frame_id = ros_node->get_name();
    frame.height = img->get_height();
    frame.width = img->get_width();
    frame.encoding = "rgb8";
    frame.is_bigendian = false;
    frame.step = img->get_width() * 3;

    // Copy image data
    PackedByteArray data = img->get_data();
    frame.data.resize(data.size());
    std::memcpy(frame.data.data(), data.ptrw(), data.size());

    // Publish image
    image_publisher->publish(std::move(frame));

    // Publish a minimal transform for correcting image position
    std::string node_name(reinterpret_cast<const char *>(get_name().to_utf8_buffer().ptr()), get_name().to_utf8_buffer().size());

    transformStamped.header.stamp = ros_node->now();
    transformStamped.header.frame_id =  node_name;
    transformStamped.child_frame_id = "camera_frame";

    // Set rotation
    tf2::Quaternion q;
    q.setRPY(-3.1416/2, 0, 3.1416/2); 
    transformStamped.transform.rotation.x = q.x();
    transformStamped.transform.rotation.y = q.y();
    transformStamped.transform.rotation.z = q.z();
    transformStamped.transform.rotation.w = q.w();


    tf_broadcaster->sendTransform(transformStamped);

    // Publish Camera Info
    // Calculate focal length based on FOV
    double focal_length_pixels = (resolution.y / 2.0) / tan(fov * M_PI / 360.0); // divide by 2 for half-angle
    // Fill message
    info.header.stamp = ros_node->now();
    info.header.frame_id = "camera_frame";
    info.height = resolution.y;
    info.width = resolution.x;
    info.distortion_model = "plumb_bob";
    info.d = std::vector<double>(5, 0.0); // No distortion
    info.k = {                            // Camera matrix
              focal_length_pixels, 0.0, resolution.x / 2.0,
              0.0, focal_length_pixels, resolution.y / 2.0,
              0.0, 0.0, 1.0};
    info.r = {// Rectification matrix
              1.0, 0.0, 0.0,
              0.0, 1.0, 0.0,
              0.0, 0.0, 1.0};

    info.p = {// Projection matrix
              focal_length_pixels, 0.0, resolution.x / 2.0, 0.0,
              0.0, focal_length_pixels, resolution.y / 2.0, 0.0,
              0.0, 0.0, 1.0, 0.0};
    info_publisher->publish(std::move(info));
}

void MirenaCam::_update_camera_settings()
{
    if (!camera)
        return;

    camera->set_as_top_level(1);
    camera->set_fov(fov);
    camera->set_near(near_clip);
    camera->set_far(far_clip);
    camera->set_projection(projection_type);
    camera->set_size(size_ortho);
    camera->set_h_offset(h_offset);
    camera->set_v_offset(v_offset);
    camera->set_doppler_tracking(doppler_tracking ? Camera3D::DOPPLER_TRACKING_IDLE_STEP : Camera3D::DOPPLER_TRACKING_DISABLED);
}

void MirenaCam::dump_group_bbox_to_yolo(const StringName &group_name)
{
    String yolo_annotations;

    // Get all group members (From the cones group for example)
    TypedArray<Node> group_nodes = get_tree()->get_current_scene()->get_tree()->get_nodes_in_group(group_name);

    godot::UtilityFunctions::print("Nodes found " + String::num(group_nodes.size()));
    // Iterate through each of them and get bound boxes
    for (int i = 0; i < group_nodes.size(); i++)
    {
        godot::UtilityFunctions::print("Node: " + String::num(i));
        // Cast to Node3D
        Node3D *node_3d = Object::cast_to<Node3D>(group_nodes[i]);
        if (!node_3d)
        {
            godot::UtilityFunctions::print("Not node3D");

            continue;
        }
        // Check if the object is behind the camera
        if (!camera->is_position_in_frustum(node_3d->get_global_transform().origin))
        {
            godot::UtilityFunctions::print("Out of frustum");
            continue;
        }

        Rect2 cone_area = getScreenSize(node_3d);
        Rect2 frame_area = Rect2(Vector2(0, 0), get_resolution()); // Frame rectangle

        if (!frame_area.encloses(cone_area) || cone_area.get_area() < AREA_THRESHOLD) // Area mayor que 40 pixeles cuadrados o fuera de ella
        {
            godot::UtilityFunctions::print("Too small on viewport to process or outside it");
            continue;
        }

        // Get centers in pixels and width and height
        float x = cone_area.get_center().x;
        float y = cone_area.get_center().y;
        float width = cone_area.get_size().x;
        float height = cone_area.get_size().y;

        // Viewport
        //  Check if Cone is in viewport and is big enough

        // Decide type
        Dictionary type_to_class_id;
        type_to_class_id["blue"] = 0;
        type_to_class_id["yellow"] = 1;
        type_to_class_id["orange"] = 2;

        godot::UtilityFunctions::print("Type is: " + String(node_3d->get_meta("type")));
        // <class_id> <x_center> <y_center> <width> <height>
        yolo_annotations += vformat("%d %f %f %f %f\n",
                                    type_to_class_id[node_3d->get_meta("type")].operator int(),
                                    x / get_resolution().x,
                                    y / get_resolution().y,
                                    width / get_resolution().x,
                                    height / get_resolution().y);
    }
    godot::UtilityFunctions::print(yolo_annotations);
    // Store on file with pic
    // Ensure dirs
    Ref<DirAccess> dir = DirAccess::open("");
    dir->dir_exists(datasetPath + "/images") ? OK : dir->make_dir_recursive(datasetPath + "/images");
    dir->dir_exists(datasetPath + "/labels") ? OK : dir->make_dir_recursive(datasetPath + "/labels");

    // Get UUID for file
    String filename = generate_uuid(); // Generate unique name for file
    // Pic
    Ref<Image> img = viewport->get_texture()->get_image();
    img->save_png(datasetPath + "/images/" + filename + ".png");

    // Anotations
    Ref<FileAccess> file = FileAccess::open(datasetPath + "/labels/" + filename + ".txt", FileAccess::WRITE);
    if (file.is_valid())
    {
        file->store_string(yolo_annotations);
        file->close();
        godot::UtilityFunctions::print("ANOTATIONS WRITEN");
    }
}

void MirenaCam::dump_group_keypoints(const StringName &group_name)
{
    // Get all group members (From the cones group for example)
    TypedArray<Node> group_nodes = get_tree()->get_current_scene()->get_tree()->get_nodes_in_group(group_name);

    godot::UtilityFunctions::print("Nodes found " + String::num(group_nodes.size()));
    // Iterate through each of the cones-> Generate the keypoints facing camera -> Project them and crop the viewport to that cone
    for (int i = 0; i < group_nodes.size(); i++)
    {
        godot::UtilityFunctions::print("Node: " + String::num(i));
        // Cast to Node3D
        Node3D *node_3d = Object::cast_to<Node3D>(group_nodes[i]);
        if (!node_3d)
        {
            godot::UtilityFunctions::print("Not node3D");
            continue;
        }
        // Check if the object is behind the camera
        if (!camera->is_position_in_frustum(node_3d->get_global_transform().origin))
        {
            godot::UtilityFunctions::print("Out of frustum");
            continue;
        }

        // Test if its inside it and big enough
        Rect2 cone_area = getScreenSize(node_3d);
        Rect2 frame_area = Rect2(Vector2(0, 0), get_resolution()); // Frame rectangle

        if (!frame_area.encloses(cone_area) || cone_area.get_area() < AREA_THRESHOLD) // Area menor que 40 pixeles cuadrados o fuera de ella
        {
            godot::UtilityFunctions::print("Too small on viewport to process or outside it");
            continue;
        }

        // Get Bounding box  (Origin + Size)
        // Mesh object
        MeshInstance3D *mesh = find_mesh_in_node(node_3d);
        // Get AABB in global space using the mesh transform
        AABB mesh_aabb = mesh->get_aabb();

        // Get AABB origin
        Vector3 bottomCenter = mesh_aabb.get_position() + Vector3(mesh_aabb.get_size().x / 2.0, 0, mesh_aabb.get_size().z / 2.0); // Get mesh bottom center in global space
        // Generate Axis aligned keypoints
        // Here is where actual order is decided
        std::vector<Vector3> points = {
            bottomCenter + Vector3(-0.075, 0.035, 0),
            bottomCenter + Vector3(0.075, 0.035, 0),
            bottomCenter + Vector3(-0.055, 0.140, 0),
            bottomCenter + Vector3(0.055, 0.140, 0),
            bottomCenter + Vector3(-0.035, 0.240, 0),
            bottomCenter + Vector3(0.035, 0.240, 0),
            bottomCenter + Vector3(0.000, 0.325, 0)};

        // Create a keypoint node3d container
        Node3D *keypoints = memnew(Node3D);
        node_3d->add_child(keypoints);

        for (unsigned int j = 0; j < points.size(); ++j)
        {
            // Create a child Node3D for each point and assign it a name
            Node3D *point_node = memnew(Node3D);
            point_node->set_name(String::num_int64(j + 1)); // Names: 1,2,3,4,5,6,7
            // Set the position of the point node
            point_node->set_position(points[j]);

            // Add the point node as a child of the parent node
            keypoints->add_child(point_node);

            // Create a sphere for visualization
            MeshInstance3D *sphere = memnew(MeshInstance3D);
            Ref<SphereMesh> sphere_mesh = memnew(SphereMesh);

            sphere_mesh->set_radius(0.02); // Small sphere for visualization
            sphere_mesh->set_height(0.04);

            Ref<StandardMaterial3D> material = memnew(StandardMaterial3D);
            material->set_albedo(Color(1.0, 0.0, 0.0)); // Red color
            sphere->set_material_override(material);
            sphere->set_mesh(sphere_mesh);

            // Add the sphere as a child of the point node
            point_node->add_child(sphere);
        }

        // Rotate the keypoints to face  camera at this instant
        //This means that the plane of the keypoints is decided by the vertical axis of the cone
        //and the crossproduct of it with the normal vector of the camera

        //Get cone vertical axis
        Vector3 cone_v_axis = node_3d->get_global_transform().basis.get_column(1).normalized();

        //Use vertical axis and camera position to get the final transform
        Transform3D keypoint_transform = keypoints->get_global_transform().looking_at(camera->get_global_transform().origin, cone_v_axis); // Align the keypoints with the camera's forward direction

        // Apply the new transform to the keypoints
        keypoints->set_global_transform(keypoint_transform);

        // Setup the positions file
        String points_str;
        // Project each point to screen space
        int n = keypoints->get_child_count(); // Get number of points
        for (int j = 0; j < n; j++)
        {
            Node3D *point = Object::cast_to<Node3D>(keypoints->get_child(j));                                                                             // get the 3d nodes
            Vector2 p_coords = camera->unproject_position(point->get_global_position());                                                                  // Unproject the points global position to camera
            points_str += vformat("%s,%.2f,%.2f\n", point->get_name(), p_coords.x - cone_area.get_position().x, p_coords.y - cone_area.get_position().y); // Write point to string substracting the area origin
        }
        // Crop viewport and store image + keycoords

        // Ensure dirs
        Ref<DirAccess> dir = DirAccess::open("");
        dir->dir_exists(datasetPath + "/images") ? OK : dir->make_dir_recursive(datasetPath + "/images");
        dir->dir_exists(datasetPath + "/labels") ? OK : dir->make_dir_recursive(datasetPath + "/labels");
        // Get UUID for file
        String filename = generate_uuid(); // Generate unique name for file
        Ref<Image> cone = viewport->get_texture()->get_image()->get_region(cone_area);
        cone->save_png(datasetPath + "/images/" + filename + ".png");
        // Save annotations
        Ref<FileAccess> file = FileAccess::open(datasetPath + "/labels/" + filename + ".csv", FileAccess::WRITE);
        if (file.is_valid())
        {
            file->store_string(points_str);
            file->close();
            godot::UtilityFunctions::print("KEYPOINTSS WRITEN");
        }
        // Finished this cone, delete keypoints
        keypoints->queue_free();
    }
}

MeshInstance3D *MirenaCam::find_mesh_in_node(Node3D *node)
{
    // Check if this node is a MeshInstance3D
    if (auto mesh_instance = Object::cast_to<MeshInstance3D>(node))
    {
        return mesh_instance;
    }

    // Recursively check all children nodes
    Array children = node->get_children();
    for (int i = 0; i < children.size(); ++i)
    {
        // Properly cast the Variant to Node* using cast_to
        Node *child = Object::cast_to<Node>(children[i]);
        if (child)
        {
            if (auto found = find_mesh_in_node(Object::cast_to<Node3D>(child)))
            {
                return found;
            }
        }
    }

    return nullptr; // Return nullptr if no MeshInstance3D is found
}

//------------------------------------------[Dataset Aux]------------------------------------------------//

// Returns a rect with the viewport size of a given node3d containing a mesh
Rect2 MirenaCam::getScreenSize(Node3D *node_3d)
{
    // Get Bounding box  (Origin + Size)
    // Mesh object
    MeshInstance3D *mesh = find_mesh_in_node(node_3d);
    // Get AABB in global space using the mesh transform
    Transform3D mesh_transform = mesh->get_global_transform();
    AABB mesh_aabb = mesh_transform.xform(mesh->get_aabb());

    // Get the corners of the AABB
    // Vector3 position = mesh_aabb.position; // Get position in global space
    Vector3 size = mesh_aabb.size;
    Vector3 corners[8] = {// Cube
                          mesh_aabb.position,
                          mesh_aabb.position + Vector3(size.x, 0, 0),
                          mesh_aabb.position + Vector3(0, size.y, 0),
                          mesh_aabb.position + Vector3(size.x, size.y, 0),
                          mesh_aabb.position + Vector3(0, 0, size.z),
                          mesh_aabb.position + Vector3(size.x, 0, size.z),
                          mesh_aabb.position + Vector3(0, size.y, size.z),
                          mesh_aabb.position + size};

    // Project each corner to screen space
    std::vector<Vector2> projected_corners;
    for (const auto &corner : corners)
    {
        projected_corners.push_back(camera->unproject_position(corner));
        godot::UtilityFunctions::print("Corner pos x: " + String::num(camera->unproject_position(corner).x) + "y: " + String::num(camera->unproject_position(corner).x));
    }

    // Find min and max of screen-space corners to create bounding rectangle
    float min_x = projected_corners[0].x;
    float max_x = projected_corners[0].x;
    float min_y = projected_corners[0].y;
    float max_y = projected_corners[0].y;

    for (const auto &corner : projected_corners)
    {
        min_x = std::min(min_x, corner.x);
        max_x = std::max(max_x, corner.x);
        min_y = std::min(min_y, corner.y);
        max_y = std::max(max_y, corner.y);
    }

    // Return a Rect
    return Rect2(min_x, min_y, max_x - min_x, max_y - min_y);
}

String MirenaCam::generate_uuid()
{
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<uint32_t> dis(0, 15);
    std::stringstream uuid;
    const char *hex = "0123456789abcdef";

    for (int i = 0; i < 32; i++)
    {
        if (i == 8 || i == 12 || i == 16 || i == 20)
            uuid << "-";
        uuid << hex[dis(gen)];
    }

    return String(uuid.str().c_str());
}

//-------------------------------------------------------------[Getters and setters]----------------------------------------------------------------------//

void MirenaCam::set_dataset_path(String path)
{
    datasetPath = path;
}

String MirenaCam::get_dataset_path(void)
{
    return datasetPath;
}

void MirenaCam::set_resolution(Vector2i res)
{
    resolution = res;
    if (viewport)
    {
        viewport->set_size(resolution);
    }
}

Vector2i MirenaCam::get_resolution() const
{
    return resolution;
}

void MirenaCam::set_use_environment(bool enable)
{
    use_environment = enable;
    if (viewport && enable)
    {
        Viewport *main_viewport = get_viewport();
        if (main_viewport && main_viewport->get_world_3d().is_valid())
        {
            viewport->set_world_3d(main_viewport->get_world_3d());
        }
    }
}

bool MirenaCam::get_use_environment() const
{
    return use_environment;
}

void MirenaCam::set_camera_position(Vector3 position)
{
    if (camera)
    {
        camera->set_position(position);
    }
}

Vector3 MirenaCam::get_camera_position() const
{
    return camera ? camera->get_position() : Vector3();
}

void MirenaCam::set_camera_rotation(Vector3 rotation)
{
    if (camera)
    {
        camera->set_rotation(rotation);
    }
}

Vector3 MirenaCam::get_camera_rotation() const
{
    return camera ? camera->get_rotation() : Vector3();
}

// Camera settings methods
void MirenaCam::set_fov(float p_fov)
{
    fov = p_fov;
    if (camera)
        camera->set_fov(fov);
}

float MirenaCam::get_fov() const
{
    return fov;
}

void MirenaCam::set_near_clip(float p_near)
{
    near_clip = p_near;
    if (camera)
        camera->set_near(near_clip);
}

float MirenaCam::get_near_clip() const
{
    return near_clip;
}

void MirenaCam::set_far_clip(float p_far)
{
    far_clip = p_far;
    if (camera)
        camera->set_far(far_clip);
}

float MirenaCam::get_far_clip() const
{
    return far_clip;
}

void MirenaCam::set_projection_type(Camera3D::ProjectionType p_type)
{
    projection_type = p_type;
    if (camera)
        camera->set_projection(projection_type);
}

Camera3D::ProjectionType MirenaCam::get_projection_type() const
{
    return projection_type;
}

void MirenaCam::set_size_ortho(float p_size)
{
    size_ortho = p_size;
    if (camera)
        camera->set_size(size_ortho);
}

float MirenaCam::get_size_ortho() const
{
    return size_ortho;
}

void MirenaCam::set_h_offset(float p_offset)
{
    h_offset = p_offset;
    if (camera)
        camera->set_h_offset(h_offset);
}

float MirenaCam::get_h_offset() const
{
    return h_offset;
}

void MirenaCam::set_v_offset(float p_offset)
{
    v_offset = p_offset;
    if (camera)
        camera->set_v_offset(v_offset);
}

float MirenaCam::get_v_offset() const
{
    return v_offset;
}

void MirenaCam::set_doppler_tracking(bool p_enable)
{
    doppler_tracking = p_enable;
    if (camera)
    {
        camera->set_doppler_tracking(doppler_tracking ? Camera3D::DOPPLER_TRACKING_IDLE_STEP : Camera3D::DOPPLER_TRACKING_DISABLED);
    }
}

bool MirenaCam::get_doppler_tracking() const
{
    return doppler_tracking;
}