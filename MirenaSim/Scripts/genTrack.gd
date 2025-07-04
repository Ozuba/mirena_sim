extends Node2D

var noise = FastNoiseLite.new()
var width = 800
var height = 800
var cell_size = 5
var closed_contours = []  # Stores separate closed contour paths

func _ready():
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.01
	find_contours()
	queue_redraw()

func find_contours():
	var grid = []
	var edge_map = {}  # Dictionary to store unique edges

	# Generate noise grid
	for x in range(width / cell_size + 1):
		grid.append([])
		for y in range(height / cell_size + 1):
			grid[x].append(noise.get_noise_2d(x * cell_size, y * cell_size))

	# Process each cell using Marching Squares
	var threshold = 0.02
	for x in range(len(grid) - 1):
		for y in range(len(grid[0]) - 1):
			var corners = [grid[x][y], grid[x+1][y], grid[x+1][y+1], grid[x][y+1]]
			var points = []
			
			# Define possible edges with interpolated points
			var cell_edges = [
				[0, 1, Vector2(x * cell_size, y * cell_size), 
					   Vector2((x + 1) * cell_size, y * cell_size)],
				[1, 2, Vector2((x + 1) * cell_size, y * cell_size), 
					   Vector2((x + 1) * cell_size, (y + 1) * cell_size)],
				[2, 3, Vector2((x + 1) * cell_size, (y + 1) * cell_size), 
					   Vector2(x * cell_size, (y + 1) * cell_size)],
				[3, 0, Vector2(x * cell_size, (y + 1) * cell_size), 
					   Vector2(x * cell_size, y * cell_size)]
			]

			# Find interpolated contour points
			for edge in cell_edges:
				if (corners[edge[0]] - threshold) * (corners[edge[1]] - threshold) < 0:
					var t = (threshold - corners[edge[0]]) / (corners[edge[1]] - corners[edge[0]])
					var point = edge[2].lerp(edge[3], t)
					points.append(point)

			# Store unique edges in a dictionary
			if points.size() >= 2:
				for i in range(0, points.size(), 2):
					if i + 1 < points.size():
						# Convert Vector2 to a string key to store in dictionary
						var edge_key = [points[i], points[i + 1]]
						edge_key.sort()  # Ensure consistent order
						var edge_str = str(edge_key[0]) + "|" + str(edge_key[1])  # Unique key
						edge_map[edge_str] = edge_key

	# Extract closed contours from the edge map
	closed_contours = extract_closed_contours(edge_map)

func extract_closed_contours(edge_map):
	var contours = []
	var visited = {}  # Track visited edges

	for edge_str in edge_map.keys():
		if visited.has(edge_str):
			continue  # Skip already tracked edges

		# Start a new contour
		var contour = []
		var edge = edge_map[edge_str]
		var start = edge[0]
		var current = edge[1]
		visited[edge_str] = true
		contour.append(start)
		contour.append(current)

		# Follow the contour until a full loop is formed
		while current != start:
			var next_edge_str = null
			for other_edge_str in edge_map.keys():
				if visited.has(other_edge_str):
					continue
				var other_edge = edge_map[other_edge_str]
				if other_edge[0] == current:
					next_edge_str = other_edge_str
					break
				elif other_edge[1] == current:
					next_edge_str = other_edge_str
					# **Manually swap points instead of calling invert()**
					edge_map[next_edge_str] = [other_edge[1], other_edge[0]]
					break

			if next_edge_str == null:
				break  # Open contour (shouldn't happen in proper marching squares)

			# Continue path
			current = edge_map[next_edge_str][1]
			visited[next_edge_str] = true
			contour.append(current)

		# Ensure it's a closed loop before storing
		if contour[0] == contour[-1]:
			contours.append(contour)

	return contours

func _draw():
	# Draw the closed contours
	var contour = closed_contours.pick_random()
	while true:
		contour = closed_contours.pick_random()
		if len(contour) > 50:
			break
	for i in range(len(contour) - 1):
		draw_line(contour[i], contour[i + 1], Color.WHITE, 1.5)
