extends Node

const MAX_SCORE_KEY = "max_score"
const PIXEL_IN_METER = 43.0
const CHECKPOINT_DIFF = PIXEL_IN_METER
const FAST_MULTIPLIER = 3

signal max_score_updated
signal score_updated

var rng = RandomNumberGenerator.new()

var max_score: int

var is_fast: bool
var checkpoint: int
var current_meters: int
var current_score: int


func _ready() -> void:
	Storage.load_from_cache()
	max_score = Storage.get_value(MAX_SCORE_KEY, 0)


func reset():
	is_fast = false
	checkpoint = 0
	current_score = 0
	current_meters = 0
	score_updated.emit()


func set_is_fast(_is_fast: int):
	is_fast = _is_fast


func moved(new_y: float):
	var passed = int(new_y) - checkpoint
	current_meters += get_meters(passed)
	current_score += get_meters(passed) * get_multiplier()
	score_updated.emit()
	checkpoint = new_y


func finish():
	save_score_if_needed()


func save_score_if_needed():
	if current_score > max_score:
		max_score = current_score
		Storage.set_value(MAX_SCORE_KEY, max_score)
		max_score_updated.emit()
		Storage.save_to_cache()


func get_meters(pixels: float) -> float:
	return pixels / PIXEL_IN_METER


func get_multiplier() -> int:
	return FAST_MULTIPLIER if is_fast else 1
