class_name Surface

var slip_speed = 400  # Speed where traction is reduced
var traction_fast = 0.3  # High-speed traction
var traction_slow = 0.7  # Low-speed traction
var friction = -0.9
var track_intensity = 0.0
var track_drift_intensity = 0.0
var dust_color: Color = Color.WHITE

enum TYPE { ASPHALT, DIRT, GRASS, SAND, SNOW, ICE, GRAVEL }

static func surface_for_type(type: Surface.TYPE) -> Surface:
	var s = Surface.new()
	match type:
		Surface.TYPE.ASPHALT:
			s.slip_speed = 400
			s.traction_fast = 0.9
			s.traction_slow = 1.0
			s.friction = -0.1
			s.track_intensity = 0.05
			s.track_drift_intensity = 0.1
			s.dust_color = Color.DIM_GRAY
		Surface.TYPE.DIRT:
			s.slip_speed = 400
			s.traction_fast = 0.5
			s.traction_slow = 0.7
			s.friction = -0.5
		Surface.TYPE.GRASS:
			s.slip_speed = 400
			s.traction_fast = 0.6
			s.traction_slow = 0.2
			s.friction = -0.3
		Surface.TYPE.SAND:
			s.slip_speed = 400
			s.traction_fast = 0.5
			s.traction_slow = 0.3
			s.friction = -0.9
		Surface.TYPE.SNOW:
			s.slip_speed = 400
			s.traction_fast = 0.7
			s.traction_slow = 0.2
			s.friction = -0.5
		Surface.TYPE.ICE:
			s.slip_speed = 400
			s.traction_fast = 0.9
			s.traction_slow = 0.1
			s.friction = -0.3
		Surface.TYPE.GRAVEL:
			s.slip_speed = 400
			s.traction_fast = 0.5
			s.traction_slow = 0.5
			s.friction = -0.6
	return s
