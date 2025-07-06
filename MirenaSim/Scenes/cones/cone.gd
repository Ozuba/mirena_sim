extends Node3D
class_name Cone

signal collided_with_vehicle;

enum color {BLUE, YELLOW, ORANGE}
var type = color.BLUE

func set_type(_type : color ):
		type = _type
		match type:
			color.BLUE:
				$Model.mesh = load("res://Assets/Models/Cone/Meshes/BCone.res")
			color.YELLOW:
				$Model.mesh = load("res://Assets/Models/Cone/Meshes/YCone.res")
			color.ORANGE:
				$Model.mesh = load("res://Assets/Models/Cone/Meshes/OCone.res")

func _on_body_entered(body: Node) -> void:
	if body == SIM.get_vehicle():
		collided_with_vehicle.emit()
