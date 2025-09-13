class_name MapSegmentConfig

const chance_of_transition = 0.3
const object_intencity_min = 0.1
const object_intencity_max = 0.9
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
	

static func generate_initial(initial_surface: Surface.TYPE = -1) -> MapSegmentConfig:
	var initial = MapSegmentConfig.new()
	initial.type = TYPE.SURFACE
	initial.surface = initial_surface if initial_surface > -1 else random_surface()
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

static func setup_static(config: MapSegmentConfig):
	config.object_intencity = random_object_intencity()
	config.template = random_template()

static func random_object_intencity() -> float:
	return rng.randf_range(object_intencity_min, object_intencity_max)

static func random_template() -> float:
	return rng.randi_range(0, tempaletes_count - 1)
