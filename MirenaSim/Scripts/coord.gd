class_name coord

const EARTH_RADIUS = 6371000.0  # To derive distances

static var cdOrigin = [0.0,0.0] # lat long in rads

static func latlon2xy(coords):
	var RadCoords = deg_to_rad(coords)	
	# X and Y calculations based on Equirectangular projection
	return Vector2(EARTH_RADIUS * (coords[1] - cdOrigin[1]) * cos(cdOrigin[0]),EARTH_RADIUS * (coords[0] - cdOrigin[0]))


static func xy2latlon(pos : Vector2):
	# Reverse Equirectangular projection formula
	return [rad_to_deg(pos.y / EARTH_RADIUS + cdOrigin[0]),rad_to_deg(pos.x / (EARTH_RADIUS * cos(cdOrigin[0])) + cdOrigin[1])]
	
	
