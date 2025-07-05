#include "register_types.h"
#include <gdextension_interface.h>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

using namespace godot;
using namespace mirena;
// Modules initialization
void mirenasim_init(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
	{
		return;
	}
	
    //auto context = std::make_shared<rclcpp::Context>();
    //    context->init(0, nullptr);
    //auto node = std::make_shared<rclcpp::Node>("godot_node", rclcpp::NodeOptions().context(context));
    

	// Launch The ROS2 Context
	if (!rclcpp::ok())
	{
		rclcpp::init(0, nullptr); // Initialize ROS2, if not already initialized
		godot::UtilityFunctions::print("ROS2 Context Launched");
	}

	GDREGISTER_CLASS(RosNode3D);
	GDREGISTER_CLASS(MirenaCarBase);
	GDREGISTER_CLASS(MirenaCam);
	GDREGISTER_CLASS(MirenaLidar);
	GDREGISTER_CLASS(MirenaImu);
	GDREGISTER_CLASS(MirenaGPS);
	GDREGISTER_CLASS(RosTime);
}

void mirenasim_deinit(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
	{
		return;
	}

	godot::UtilityFunctions::print("ROS2 Context Shut down");
	rclcpp::shutdown(); 
}

extern "C"
{
	// Initialization.
	GDExtensionBool GDE_EXPORT mirenaros_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, const GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization)
	{
		godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

		init_obj.register_initializer(mirenasim_init);
		init_obj.register_terminator(mirenasim_deinit);
		init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

		return init_obj.init();
	}
}
