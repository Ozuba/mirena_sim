#pragma once

#include <godot_cpp/classes/ref_counted.hpp>
#include "mirena_common/msg/entity.hpp"
#include "mirena_common/msg/car.hpp"

// Almost pure data types used to allow building and unpacking ros messages from gdscript

namespace mirena
{
        class SrvSimSetPauseRequest : public godot::RefCounted
    {
        GDCLASS(SrvSimSetPauseRequest, godot::RefCounted)
        
        public:
        bool paused;
        bool get_paused();

        protected:
        static void _bind_methods();
    };

        class SrvSimUnpauseForRequest : public godot::RefCounted
    {
        GDCLASS(SrvSimUnpauseForRequest, godot::RefCounted)
        
        public:
        double unpause_time;
        double get_unpause_time();

        protected:
        static void _bind_methods();
    };
}

namespace mirena::service_wrappers
{
    inline void register_all()
    {
        GDREGISTER_CLASS(SrvSimSetPauseRequest)
        GDREGISTER_CLASS(SrvSimUnpauseForRequest)
    }

}