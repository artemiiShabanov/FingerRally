extends Node2D

signal on_surface_changed(prev, now)

@export var car: Car

const segment_pool_size = 3
const segment_size = Vector2(5000, 5000)
const segment_scene = preload("res://Map/MapSegment/MapSegment.tscn")

var segments: Dictionary
var current_surface: Surface.TYPE
var index: int = 0:
	set(value):
		if index != value:
			index = value
			extend_if_needed()
			change_surface(segments[index].config.surface)


func _ready() -> void:
	clip_children = CLIP_CHILDREN_DISABLED
	var config = MapSegmentConfig.generate_initial()
	append_segment(0, config)
	extend_if_needed()
	current_surface = config.surface
	change_surface(config.surface)


func _process(_delta: float) -> void:
	update_index()


func update_index():
	var y = -car.global_position.y
	var current_index = floor((y + segment_size.y / 2) / segment_size.y)
	index = current_index

func extend_if_needed():
	if index == get_last_segment_key():
		extend()
		clear_segment_if_needed()


func get_first_segment_key() -> int:
	var keys = segments.keys()
	keys.sort()
	return keys[0] if keys.size() > 0 else -1


func get_last_segment_key() -> int:
	var keys = segments.keys()
	keys.sort()
	return keys[keys.size() - 1] if keys.size() > 0 else -1


func get_segment(key: int) -> MapSegment:
	return segments[key] as MapSegment


func clear_segment_if_needed():
	if segments.size() > segment_pool_size:
		var key = get_first_segment_key()
		if key >= 0:
			get_segment(key).queue_free()
			segments.erase(key)


func extend():
	var key = get_last_segment_key()
	var last_segment = get_segment(key)
	if last_segment != null:
		var _index = key + 1
		var config = last_segment.config.generate_next()
		append_segment(_index, config)


func append_segment(_index: int, config: MapSegmentConfig):
	var segment = generate_segment(config)
	segments[_index] = segment
	var x = 0
	var y = -(segment_size.y * _index) 
	place_segment(segment, x, y)


func generate_segment(config: MapSegmentConfig) -> Node2D:
	var segment = segment_scene.instantiate()
	segment.config = config
	return segment


func place_segment(segment: Node2D, x: float, y: float):
	add_child(segment)
	segment.global_position = Vector2(x, y)


func change_surface(new_type: Surface.TYPE):
	on_surface_changed.emit(current_surface, new_type)
	current_surface = new_type
	print(new_type)
	var surface = Surface.surface_for_type(new_type)
	car.set_surface(surface)
