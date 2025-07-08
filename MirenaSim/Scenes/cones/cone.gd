extends Node3D
class_name Cone

signal collided_with_vehicle;

enum ConeColor {BLUE, YELLOW, ORANGE}
static var blue_mesh = preload("res://Assets/Models/Cone/Meshes/BCone.res")
static var yellow_mesh = preload("res://Assets/Models/Cone/Meshes/YCone.res")
static var orange_mesh = preload("res://Assets/Models/Cone/Meshes/OCone.res")

var type : ConeColor = ConeColor.BLUE:
	set(_type):
		type = _type
		match type:
			ConeColor.BLUE:
				$Model.mesh = blue_mesh
			ConeColor.YELLOW:
				$Model.mesh = yellow_mesh
			ConeColor.ORANGE:
				$Model.mesh = orange_mesh

func get_type_as_string() -> String:
	match type:
		ConeColor.BLUE:
			return "Cone/Blue"
		ConeColor.YELLOW:
			return "Cone/Yellow"
		ConeColor.ORANGE:
			return "Cone/Orange"
		_:
			return "Cone"
	

func _on_body_entered(body: Node) -> void:
	if body == SIM.get_vehicle():
		collided_with_vehicle.emit()
