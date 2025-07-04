extends Node3D

enum color {BIG_ORANGE ,ORANGE, YELLOW, BLUE}
var type = color.BLUE
var moved = false # Holds if cone is intact

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
	if body.name == "vehicle" and not moved:
		moved = true # Cone already moved
		SIM.get_stats().set("cones_fallen", SIM.get_stats().get("cones_fallen") + 1)
