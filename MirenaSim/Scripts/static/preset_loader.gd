extends RefCounted
class_name PresetLoader

static func reset_sim():
	SIM.get_vehicle().reset_car()
	SIM.get_track_manager()
	MirenaLogger.disp_debug(["Not implemented"])

static func load_slam():
	MirenaLogger.disp_debug(["Not implemented"])

static func load_planning():
	MirenaLogger.disp_debug(["Not implemented"])

static func load_control():
	MirenaLogger.disp_debug(["Not implemented"])
