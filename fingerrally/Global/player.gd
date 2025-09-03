extends Node

const MAX_SCORE_KEY = "max_score"
const PIXEL_IN_METER = 43.0
const CHECKPOINT_DIFF = PIXEL_IN_METER
const GEAR_MULTIPLIERS = [0, 1, 2, 3, 4, 5, 6, 7]

signal max_score_updated
signal score_updated

var rng = RandomNumberGenerator.new()

var max_score: int

var gear: int
var checkpoint: int
var current_meters: int
var current_score: int


func _ready() -> void:
	Storage.load_from_cache()
	max_score = Storage.get_value(MAX_SCORE_KEY, 0)


func reset():
	gear = 0
	checkpoint = 0
	current_score = 0
	current_meters = 0
	score_updated.emit()


func set_gear(_gear: int):
	gear = _gear


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
		Storage.set_value(MAX_SCORE_KEY, max_score)
		max_score = current_score
		max_score_updated.emit()
		Storage.save_to_cache()


func get_meters(pixels: float) -> float:
	return pixels / PIXEL_IN_METER


func get_multiplier() -> int:
	return GEAR_MULTIPLIERS[gear]
