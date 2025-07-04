extends AVehiclePilot
## Dummy Pilot that does not move the car, and does nothing to it
class_name NoPilot

func _to_string() -> String:
	return "No Pilot"
