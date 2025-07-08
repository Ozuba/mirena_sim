#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include "mirena_common/msg/entity.hpp"
#include "mirena_common/msg/car.hpp"

// Almost pure data types used to allow building and unpacking ros messages from gdscript

namespace mirena
{
    class SrvGetEntitiesRequest : public godot::RefCounted
    {
        GDCLASS(SrvGetEntitiesRequest, godot::RefCounted)

        protected:
        static void _bind_methods();
    };

    class SrvGetEntitiesResponse : public godot::RefCounted
    {
        GDCLASS(SrvGetEntitiesResponse, godot::RefCounted)

    public:
        void add_entity(const godot::Vector3& pos, const godot::String& type, double confidence);
        
        std::vector<mirena_common::msg::Entity> entities;

    protected:
        static void _bind_methods();
    };

    class SrvGetCarRequest : public godot::RefCounted
    {
        GDCLASS(SrvGetCarRequest, godot::RefCounted)

    protected:
        static void _bind_methods();
    };

    class SrvGetCarResponse : public godot::RefCounted
    {
        GDCLASS(SrvGetCarResponse, godot::RefCounted)

    public:
        void set_car_state(const godot::Vector3 &position, const godot::Vector3 &rotation, const godot::Vector3 &lin_speed, const godot::Vector3 &ang_speed, const godot::Vector3 &lin_accel, const godot::Vector3 &ang_accel);
        mirena_common::msg::Car car_state;
    protected:
        static void _bind_methods();
    };
}

namespace mirena::service_wrappers
{
    inline void register_all()
    {
        GDREGISTER_CLASS(SrvGetEntitiesRequest)
        GDREGISTER_CLASS(SrvGetEntitiesResponse)
        GDREGISTER_CLASS(SrvGetCarRequest)
        GDREGISTER_CLASS(SrvGetCarResponse)
    }

}