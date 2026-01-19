@tool
extends Area3D
class_name Gate
signal vehicle_passed

enum GateType { 
	STANDARD, # Normal directional Gate
	EVENT,   # Race start Gate
}
## The distance between the two cones.
@export var gate_width: float = 3.0:
	set(val):
		gate_width = val
		_update_layout()

## Is this an event gate?
@export var gate_type: GateType = GateType.STANDARD:
	set(val):
		gate_type = val
		_update_layout()
		


func _ready():
	_update_layout()
	# Connect signal if not in editor
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)

## Updates the positions of cones and the size of the collision box
func _update_layout():
	# Position the cones
	$LeftCone.position.x = -gate_width / 2.0
	$RightCone.position.x = gate_width / 2.0
	
	
	match gate_type:
		GateType.STANDARD:
			$LeftCone.type = Cone.ConeColor.BLUE
			$RightCone.type = Cone.ConeColor.YELLOW
		GateType.EVENT:
			$LeftCone.type = Cone.ConeColor.BIG_ORANGE
			$RightCone.type = Cone.ConeColor.BIG_ORANGE

	# Size the collision box
	$CollisionShape3D.shape.size = Vector3(gate_width, 3.0, 0.25)

func _on_body_entered(body: Node3D):
	if body.is_in_group("vehicle"):
		# Direction Check (Dot Product)
		# Forward in Godot is -Z. 
		var gate_forward = -global_transform.basis.z 
		var vehicle_velocity = body.linear_velocity.normalized()
		
		# If dot product > 0, they are moving in the same general direction
		if gate_forward.dot(vehicle_velocity) > 0.1:
			print("Valid Pass!")
			vehicle_passed.emit()
		else:
			print("Wrong Way!")
