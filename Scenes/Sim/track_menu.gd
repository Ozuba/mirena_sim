extends Control

func _ready():
	pass




func _on_generate_track():
		Sim.track.create_track()

func _on_open_track_pressed():
	$FileDialog.visible = true


func _on_track_file_selected(path: String):
	Sim.track.load_track(path)

	
func _on_enable_cone_collision_toggled(toggled_on: bool) -> void:
	Sim.car.cone_collision_set(toggled_on)


func _on_clear_track_pressed() -> void:
	Sim.track.clear_track()
