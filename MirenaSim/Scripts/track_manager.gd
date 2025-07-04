extends Node3D
class_name TrackManager

signal track_cleared

## Curve defining the track. A value of null means no track is currently loaded
var _track : Curve3D

## Exposes Followable Path for the track
var _car_path : Path3D

## Visible path mesh
var _car_path_mesh: MeshInstance3D

## Generates the cones along a path with given separation and spacing
func _gen_gates(path : Curve3D, spacing : float = 4, width : float = 3):
	# Preload Cone Scene
	
	var coneScene = load("res://Scenes/cones/cone.tscn") 
	
	#Calc Dimensions
	var length = path.get_baked_length() #Gets length
	var num_gates = int(length / spacing) # Calculates number of gates
	# Generate Startline and place car
	var start_pos = path.sample_baked(0)
	var first_pos = path.sample_baked(0 + spacing)
	var start_tan = (first_pos-start_pos).normalized()
	var start_normal = Vector3.UP.cross(start_tan).normalized()
	
	#Generate the two orange cones per side
	for i in range(4):
		var start_cone = coneScene.instantiate()
		start_cone.set_meta("type","blue")
		start_cone.set_type(start_cone.color.ORANGE)
		match i:
			0:
				start_cone.translate(start_pos + start_normal * (width / 2) + 0.3*start_tan)
			1: 
				start_cone.translate(start_pos + start_normal * (width / 2)- 0.3*start_tan)
			2:
				start_cone.translate(start_pos - start_normal * (width / 2)+ 0.3*start_tan)
			3:
				start_cone.translate(start_pos - start_normal * (width / 2)- 0.3*start_tan)
		start_cone.rotate_y(randf_range(0,PI/4))
		start_cone.add_to_group("Cones") # Add to group for easy reference
		add_child(start_cone)
	# Set car position
	# SIM.get_vehicle().set_pose(start_pos, start_theta)
	
	#Generate each gate
	for i in range(1,num_gates + 1):
		var  d = (i * spacing) # Obtiene la distancia de la puerta
		var pos = path.sample_baked(d)
		var nextPos = path.sample_baked(d + spacing)
		var tangent = (nextPos-pos).normalized()
		var normal = Vector3.UP.cross(tangent).normalized() # Get perpendicular Vector

		#Blue 
		var cone = coneScene.instantiate()
		cone.name = "G" + str(i) + "B"
		cone.set_meta("type","blue")
		cone.set_type(cone.color.BLUE)
		cone.translate(pos + normal * (width / 2))
		cone.rotate_y(randf_range(0,PI/4))
		cone.add_to_group("Cones") # Add to group for easy reference
		add_child(cone)

		#Yellow
		cone = coneScene.instantiate()
		cone.name = "G" + str(i) + "Y"
		cone.set_meta("type","yellow")
		cone.set_type(cone.color.YELLOW)
		cone.translate(pos - normal * (width / 2))
		cone.rotate_y(randf_range(0,PI/4))
		cone.add_to_group("Cones") # Add to group for easy reference
		add_child(cone)

static func _get_path3d_from_file(filepath: String) -> Curve3D:
	#Get json trackfile
	var file := FileAccess.open(filepath, FileAccess.READ)
	if file == null: return null
	var json := JSON.new()
	json.parse(file.get_as_text())
	var loaded_track = json.data
	
	# Create new path
	var ret := Curve3D.new()
	for point in loaded_track["path"]:
		ret.add_point(Vector3(point[0], 0, point[1]))
	return ret

func _generate_car_path_mesh(force_rebuild: bool = false):
	# Sanity checks
	if not self.has_active_track():
		MirenaLogger.disp_error(["Cannot generate car path because no track is currently loaded"])
		return
	if self._car_path_mesh != null:
		if not force_rebuild:
			return
		# Clean the old mesh
		self.remove_child(_car_path_mesh)
		self._car_path_mesh.queue_free()
		self._car_path_mesh = null
	
	# Actual generation starts here
	var line_mesh := ImmediateMesh.new()
	self._car_path_mesh = MeshInstance3D.new()

	# Draw the curve as a line strip
	line_mesh.clear_surfaces()
	line_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)

	for i in range(self._track.get_point_count()):
		line_mesh.surface_add_vertex(self._track.get_point_position(i))
	line_mesh.surface_end()
	
	# Add the mesh to the track
	self._car_path_mesh.mesh = line_mesh
	add_child(self._car_path_mesh)

# --------------------------------------------
# Interface 
# --------------------------------------------

func has_active_track() -> bool:
	return self._track != null

##Loads curve from a json file
func loadTrack(filepath : String) -> void:
	MirenaLogger.disp_std(["Loading Track:", filepath])
	
	# Preprocessing
	var loaded_track = self._get_path3d_from_file(filepath)
	if loaded_track == null: 
		MirenaLogger.disp_error(["Couldn't load track. Either the file doesn't exist or is in an invalid format"])
		return
	
	if self.has_active_track(): self.clear_track()
	
	#Load the path into track
	self._car_path = Path3D.new()
	
	self._track = loaded_track
	self._car_path.curve = loaded_track
	self.add_child(self._car_path) #Expose path as child
	
	#Spawn the cones
	self._gen_gates(self._track,4,3)
	
	#Show the path curve
	self.show_path()

## Clears all track contents
func clear_track():
	if not self.has_active_track(): return
	for cone in get_tree().get_nodes_in_group("Cones"):
		cone.queue_free()
	
	self._car_path.queue_free(); self._car_path = null
	self._car_path_mesh.queue_free(); self._car_path_mesh = null
	self._track = null
	
	self.track_cleared.emit()

func show_path():
	if self._car_path_mesh != null:
		self._car_path_mesh.show()
	else:
		self._generate_car_path_mesh()

func hide_path():
	if self._car_path_mesh != null:
		self._car_path_mesh.hide()

func get_car_path() -> Path3D:
	return self._car_path
