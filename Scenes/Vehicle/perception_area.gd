@tool
extends Area3D
class_name PerceptionArea
## This is not the actual lidar implementation
## Simulates what perception would produce

@onready var colision_shape = $CollisionShape3D

func _ready() -> void:
	self.regenerate_frustum(4, 12, deg_to_rad(30), deg_to_rad(60))

func get_cones_in_sigth() -> Array[Node3D]:
	return self.get_overlapping_bodies().filter(func (x : Node3D): return x.is_in_group("Cones"))

func regenerate_frustum(min_dist: float, max_dist: float, vertical_res: float, horizontal_res: float) -> void:
	# Create a new ConvexPolygonShape for the frustum
	var frustum_shape = ConvexPolygonShape3D.new()
	
	# Calculate the half dimensions at near and far planes
	var half_width_near = min_dist * tan(horizontal_res / 2.0)
	var half_height_near = min_dist * tan(vertical_res / 2.0)
	var half_width_far = max_dist * tan(horizontal_res / 2.0)
	var half_height_far = max_dist * tan(vertical_res / 2.0)
	
	# Define the 8 vertices of the frustum
	var vertices = [
		# Near plane vertices
		Vector3(-half_width_near, -half_height_near, min_dist),  # bottom-left
		Vector3(half_width_near, -half_height_near, min_dist),   # bottom-right
		Vector3(half_width_near, half_height_near, min_dist),    # top-right
		Vector3(-half_width_near, half_height_near, min_dist),   # top-left
		
		# Far plane vertices
		Vector3(-half_width_far, -half_height_far, max_dist),    # bottom-left
		Vector3(half_width_far, -half_height_far, max_dist),     # bottom-right
		Vector3(half_width_far, half_height_far, max_dist),      # top-right
		Vector3(-half_width_far, half_height_far, max_dist)      # top-left
	]
	
	# Set the vertices for the convex shape
	frustum_shape.points = vertices
	
	# Assign the shape to the collision shape
	colision_shape.shape = frustum_shape
