class_name MapSegmentConfig

const chance_of_transition = 0.3
const tempaletes_count = 10

static var rng = RandomNumberGenerator.new()

enum TYPE {
	SURFACE,
	TRANSITION,
}

var type: TYPE
var prev_surface: Surface.TYPE
var surface: Surface.TYPE
var next_surface: Surface.TYPE
var object_intencity: float
var template: int

var base_description: String:
	get:
		match type:
			TYPE.SURFACE:
				return "S" + str(surface)
			TYPE.TRANSITION:
				return "T" + str(prev_surface) + str(next_surface)
			_:
				return ""

var road_description: String:
	get:
		match type:
			TYPE.SURFACE:
				return "S" + str(surface) + str(template)
			_:
				return ""

static func generate_initial() -> MapSegmentConfig:
	var initial = MapSegmentConfig.new()
	initial.type = TYPE.TRANSITION
	initial.surface = Surface.TYPE.ASPHALT
	initial.next_surface = random_surface()
	initial.prev_surface = random_surface_exluding(initial.next_surface)
	setup_static(initial)
	return initial

func generate_next() -> MapSegmentConfig:
	var next = MapSegmentConfig.new()
	match type:
		TYPE.TRANSITION:
			next.type = TYPE.SURFACE
			next.surface = next_surface
		TYPE.SURFACE:
			if rng.randf() < chance_of_transition:
				next.type = TYPE.TRANSITION
				next.prev_surface = surface
				next.surface = Surface.TYPE.ASPHALT
				next.next_surface = random_other_surface()
			else:
				next.type = TYPE.SURFACE
				next.surface = surface
	setup_static(next)
	return next

func random_other_surface() -> Surface.TYPE:
	var all = Surface.TYPE.keys()
	all.remove_at(surface)
	all.remove_at(Surface.TYPE.ASPHALT)
	return Surface.TYPE[all.pick_random()]

static func random_surface() -> Surface.TYPE:
	var all = Surface.TYPE.keys()
	all.remove_at(Surface.TYPE.ASPHALT)
	return Surface.TYPE[all.pick_random()]

static func random_surface_exluding(ex_type: Surface.TYPE) -> Surface.TYPE:
	var all = Surface.TYPE.keys()
	all.remove_at(ex_type)
	all.remove_at(Surface.TYPE.ASPHALT)
	return Surface.TYPE[all.pick_random()]

static func setup_static(config: MapSegmentConfig):
	config.object_intencity = random_object_intencity(config.surface)
	config.template = random_template()

static func random_object_intencity(_surface: Surface.TYPE) -> float:
	match _surface:
		Surface.TYPE.ASPHALT:
			return 0
		Surface.TYPE.DIRT:
			return rng.randf_range(0.6, 0.8)
		Surface.TYPE.SNOW:
			return rng.randf_range(0.4, 0.7)
		Surface.TYPE.SAND:
			return rng.randf_range(0.2, 0.5)
		Surface.TYPE.GRAVEL:
			return rng.randf_range(0.2, 0.3)
		_:
			return 0

static func random_template() -> float:
	return rng.randi_range(1, tempaletes_count)
