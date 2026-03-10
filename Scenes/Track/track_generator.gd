class_name TrackGenerator
extends RefCounted

# --- Configurable Parameters ---
var map_size := Vector2i(512, 512)
var threshold := 0.05
var noise_frequency := 0.005
var min_polygon_size := 40

# --- Internal State ---
var noise: FastNoiseLite
var texture: NoiseTexture2D
var all_valid_loops: Array[PackedVector2Array] = []

func _init() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	noise.frequency = noise_frequency
	
	texture = NoiseTexture2D.new()
	texture.width = map_size.x
	texture.height = map_size.y
	texture.noise = noise

## Generates a new random seed and updates the internal state
func regenerate() -> void:
	noise.seed = randi()
	# We don't need to await here; the texture updates internally 
	# but the UI might want to await generator.texture.changed
	_extract_loops()

## Returns the visualization texture for UI assignment
func get_texture() -> NoiseTexture2D:
	return texture

func _extract_loops() -> void:
	var bitmap = BitMap.new()
	bitmap.create(map_size)
	
	var center = Vector2(map_size) / 2.0
	var max_dist = center.length() * 0.8

	for x in map_size.x:
		for y in map_size.y:
			var falloff = clamp(1.0 - (Vector2(x, y).distance_to(center) / max_dist), 0.0, 1.0)
			if noise.get_noise_2d(x, y) * falloff > threshold:
				bitmap.set_bit(x, y, true)

	var polys = bitmap.opaque_to_polygons(Rect2i(0, 0, map_size.x, map_size.y))
	all_valid_loops = polys.filter(func(p): return p.size() > min_polygon_size)

## Logic to convert a raw loop into a high-quality Curve3D
func create_curve_from_loop(index: int) -> Curve3D:
	if all_valid_loops.is_empty() or index >= all_valid_loops.size():
		return null
		
	var points = all_valid_loops[index]
	
	# 1. Smoothing & Simplification
	var processed = _chaikin_smooth(points, 4)
	processed = _simplify_points(processed, 1.5)
	
	# 2. Align to straightest section
	processed = _reorder_to_best_start(processed)
	
	# 3. Build & Normalize
	var bounds = _get_bounds(processed)
	var scale = 140.0 / max(bounds.size.x, bounds.size.y)
	
	var curve = Curve3D.new()
	for p in processed:
		var p2d = (p - bounds.center) * scale
		curve.add_point(Vector3(p2d.x, 0, p2d.y))
	
	curve.closed = true
	_compute_tangents(curve)
	
	# 4. Final High-res Tessellation
	var final_points = curve.tessellate(6, 4)
	var final_curve = Curve3D.new()
	final_curve.closed = true
	for p in final_points:
		final_curve.add_point(p)
		
	return final_curve

# --- Helper Math Methods ---
# (Moved here from the old UI script as internal helpers)

func _chaikin_smooth(points: PackedVector2Array, iterations: int) -> PackedVector2Array:
	var output = points
	for i in range(iterations):
		var next = PackedVector2Array()
		for j in range(output.size()):
			var p0 = output[j]
			var p1 = output[posmod(j + 1, output.size())]
			next.append(p0.lerp(p1, 0.25))
			next.append(p0.lerp(p1, 0.75))
		output = next
	return output

func _reorder_to_best_start(points: PackedVector2Array) -> PackedVector2Array:
	var best_idx = 0
	var max_score = -1.0
	for i in range(points.size()):
		var v1 = (points[i] - points[posmod(i-1, points.size())]).normalized()
		var v2 = (points[posmod(i+1, points.size())] - points[i]).normalized()
		var score = v1.dot(v2) * points[i].distance_to(points[posmod(i+1, points.size())])
		if score > max_score:
			max_score = score
			best_idx = i
	var reordered = PackedVector2Array()
	for i in range(points.size()): reordered.append(points[posmod(i + best_idx, points.size())])
	return reordered

func _compute_tangents(curve: Curve3D):
	var tightness = 0.35
	for i in range(curve.point_count):
		var curr = curve.get_point_position(i)
		var prev = curve.get_point_position(posmod(i - 1, curve.point_count))
		var next = curve.get_point_position(posmod(i + 1, curve.point_count))
		var dir = (next - prev).normalized()
		curve.set_point_in(i, -dir * (curr.distance_to(prev) * tightness))
		curve.set_point_out(i, dir * (curr.distance_to(next) * tightness))
	# Start alignment
	var s_dir = (curve.get_point_position(1) - curve.get_point_position(0)).normalized()
	curve.set_point_in(0, -s_dir * 3.0); curve.set_point_out(0, s_dir * 3.0)

func _simplify_points(pts: PackedVector2Array, e: float) -> PackedVector2Array:
	if pts.size() < 3: return pts
	var res = PackedVector2Array()
	res.append(pts[0])
	for i in range(1, pts.size() - 1):
		if res[res.size()-1].distance_to(pts[i]) > e: res.append(pts[i])
	res.append(pts[pts.size()-1])
	return res

func _get_bounds(pts: PackedVector2Array) -> Dictionary:
	var min_p = pts[0]; var max_p = pts[0]
	for p in pts:
		min_p.x = min(min_p.x, p.x); min_p.y = min(min_p.y, p.y)
		max_p.x = max(max_p.x, p.x); max_p.y = max(max_p.y, p.y)
	return {"center": min_p + ((max_p - min_p)/2.0), "size": max_p - min_p}
