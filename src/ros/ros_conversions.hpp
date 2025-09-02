#include "mirena_common/msg/bezier_curve.hpp"
#include "geometry_msgs/msg/quaternion.hpp"
#include "geometry_msgs/msg/vector3.hpp"

#include "godot_cpp/classes/curve3d.hpp"
#include "sim/ref_counted/service_wrappers.hpp"

#include "mirena_common/srv/get_entities.hpp"
#include "mirena_common/srv/get_car.hpp"
#include "mirena_common/srv/sim_set_pause.hpp"
#include "mirena_common/srv/sim_unpause_for.hpp"

namespace mirena {
    mirena_common::msg::BezierCurve to_msg(const godot::Ref<godot::Curve3D> native);
    geometry_msgs::msg::Point to_msg(const godot::Vector3& native);
    geometry_msgs::msg::Quaternion to_msg(const godot::Quaternion& native);

    geometry_msgs::msg::Vector3 to_msg_vector3(const godot::Vector3& native);

    godot::Ref<mirena::SrvGetEntitiesRequest> to_request(const std::shared_ptr<mirena_common::srv::GetEntities::Request> request);
    godot::Ref<mirena::SrvGetCarRequest> to_request(const std::shared_ptr<mirena_common::srv::GetCar::Request> request);
    godot::Ref<mirena::SrvSimSetPauseRequest> to_request(const std::shared_ptr<mirena_common::srv::SimSetPause::Request> request);
    godot::Ref<mirena::SrvSimUnpauseForRequest> to_request(const std::shared_ptr<mirena_common::srv::SimUnpauseFor::Request> request);
    void to_response(mirena::SrvGetEntitiesResponse& native_response, std::shared_ptr<mirena_common::srv::GetEntities::Response> ros_response);
    void to_response(mirena::SrvGetCarResponse& native_response, std::shared_ptr<mirena_common::srv::GetCar::Response> ros_response);

}