extends RefCounted
class_name PresetLoader

static func reset_sim():
	SIM.get_vehicle().reset_car()
	SIM.get_track_manager().clear_track()
	MirenaLogger.disp_debug(["Not (fully?) implemented"])

static func load_slam():
	var track_manager := SIM.get_track_manager()
	var vehicle := SIM.get_vehicle()
	
	track_manager.load_default_track()
	vehicle.set_pilot(ManualPilot.new(vehicle))
	vehicle.reset_car()

static func load_planning():
	var track_manager := SIM.get_track_manager()
	var vehicle := SIM.get_vehicle()
	
	track_manager.load_default_track()
	vehicle.snap_to_track_start()

static func load_control():
	MirenaLogger.disp_debug(["Not implemented"])
