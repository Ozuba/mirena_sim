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
	vehicle.snap_to_track_start()
	vehicle.set_pilot(ManualPilot.new(vehicle))
	
	ROS.enable_all_pub()

static func load_planning():
	var track_manager := SIM.get_track_manager()
	var vehicle := SIM.get_vehicle()
	
	track_manager.load_default_track()
	vehicle.snap_to_track_start()
	vehicle.set_pilot(TrackRailPilot.new(vehicle))
	
	ROS.enable_all_pub()

static func load_control():
	var track_manager := SIM.get_track_manager()
	var vehicle := SIM.get_vehicle()
	
	ROS.enable_all_pub()
	track_manager.load_default_track()
	vehicle.snap_to_track_start()
	vehicle.set_pilot(RosPilot.new(vehicle))

static func load_full_pipeline():
	var track_manager := SIM.get_track_manager()
	var vehicle := SIM.get_vehicle()
	
	ROS.disable_all_pub()
	track_manager.load_default_track()
	vehicle.snap_to_track_start()
	vehicle.set_pilot(RosPilot.new(vehicle))
