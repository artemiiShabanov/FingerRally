extends Node2D

class_name TireTrack

@export var track_intensity: float = 1.0
@export var trail_duration = 30.0
@export var max_track_length: int = 200

@onready var line = $Line2D

var isStarted = false
var startTime = 0
var time_since_start: float:
	get: return (Time.get_ticks_msec() - startTime) / 1000.0


func _ready() -> void:
	line.top_level = true

func _physics_process(_delta: float) -> void:
	if isStarted:
		emit_track()
	elif time_since_start > trail_duration:
			queue_free()

func emit_track():
	line.add_point(global_position)
	if line.points.size() > max_track_length:
		line.remove_point(0)

func start():
	isStarted = true
	startTime = Time.get_ticks_msec()  # Timestamp for when the trail was started

func stop():
	isStarted = false

func set_intensity(intensity: float):
	track_intensity = intensity
	line.modulate.a = track_intensity  # Adjust the alpha channel for intensity
