#include <godot_cpp/classes/engine.hpp>

namespace mirena
{
    inline bool running_on_editor()
    {
        return godot::Engine::get_singleton()->is_editor_hint();
    }
}