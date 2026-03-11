class_name TrackGenerator
extends RefCounted

# Original Default Values for Reference
const DEFAULT_MAP_SIZE = Vector2i(512, 512)
const DEFAULT_THRESHOLD = 0.05
const DEFAULT_FREQUENCY = 0.005
const DEFAULT_MIN_POLY_SIZE = 40
const DEFAULT_SMOOTHING = 4
const DEFAULT_SCALE = 100.0

## Full control generation method
func generate(
	world_scale: float = DEFAULT_SCALE,
	freq: float = DEFAULT_FREQUENCY,
	threshold: float = DEFAULT_THRESHOLD,
	smoothing: int = DEFAULT_SMOOTHING,
	octaves: int = 1, # Original FRACTAL_NONE is effectively 1 octave
	min_poly_size: int = DEFAULT_MIN_POLY_SIZE
) -> Curve3D:
	
	# 1. Noise Setup
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = freq
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM if octaves > 1 else FastNoiseLite.FRACTAL_NONE
	noise.fractal_octaves = octaves
	
	# 2. Grid Generation
	var bitmap = BitMap.new()
	bitmap.create(DEFAULT_MAP_SIZE)
	var center = Vector2(DEFAULT_MAP_SIZE) / 2.0
	var max_dist = center.length() * 0.8 # Original falloff logic

	for x in DEFAULT_MAP_SIZE.x:
		for y in DEFAULT_MAP_SIZE.y:
			var falloff = clamp(1.0 - (Vector2(x, y).distance_to(center) / max_dist), 0.0, 1.0)
			if noise.get_noise_2d(x, y) * falloff > threshold:
				bitmap.set_bit(x, y, true)

	# 3. Polygon Extraction
	var polys = bitmap.opaque_to_polygons(Rect2i(0, 0, DEFAULT_MAP_SIZE.x, DEFAULT_MAP_SIZE.y))
	# Filter by size just like the original
	var valid_polys = polys.filter(func(p): return p.size() > min_poly_size)
	
	if valid_polys.is_empty(): return null
	
	# Pick the largest one to ensure a single main loop
	valid_polys.sort_custom(func(a, b): return a.size() > b.size())
	var raw_points = valid_polys[0]

	# 4. Smoothing (Chaikin's Algorithm)
	var processed = _chaikin_smooth(raw_points, smoothing)
	
	# 5. Build Curve3D
	var bounds = _get_bounds(processed)
	var scale_factor = world_scale / max(bounds.size.x, bounds.size.y)
	
	var curve = Curve3D.new()
	curve.closed = true
	
	for p in processed:
		var p2d = (p - bounds.center) * scale_factor
		curve.add_point(Vector3(p2d.x, 0, p2d.y))
	
	# Apply tangents for the "soft" look
	_compute_tangents(curve, 0.35)
	
	return curve

# --- Math Helpers (Same as before) ---

func _chaikin_smooth(points: PackedVector2Array, iterations: int) -> PackedVector2Array:
	var output = points
	for i in iterations:
		var next = PackedVector2Array()
		for j in output.size():
			var p0 = output[j]
			var p1 = output[(j + 1) % output.size()]
			next.append(p0.lerp(p1, 0.25))
			next.append(p0.lerp(p1, 0.75))
		output = next
	return output

func _compute_tangents(curve: Curve3D, tightness: float):
	for i in curve.point_count:
		var curr = curve.get_point_position(i)
		var prev = curve.get_point_position(posmod(i - 1, curve.point_count))
		var next = curve.get_point_position(posmod(i + 1, curve.point_count))
		var dir = (next - prev).normalized()
		var dist = curr.distance_to(next) * tightness
		curve.set_point_in(i, -dir * dist)
		curve.set_point_out(i, dir * dist)

func _get_bounds(pts: PackedVector2Array) -> Dictionary:
	var min_p = pts[0]; var max_p = pts[0]
	for p in pts:
		min_p.x = min(min_p.x, p.x); min_p.y = min(min_p.y, p.y)
		max_p.x = max(max_p.x, p.x); max_p.y = max(max_p.y, p.y)
	return {"center": min_p + ((max_p - min_p)/2.0), "size": max_p - min_p}
