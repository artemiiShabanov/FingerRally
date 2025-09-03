extends Control

@export var car: Car

signal pause(paused)
signal restart

const speed_ratio = 10

@onready var speed_label =  $TopContainer/HBoxContainer/VBoxContainer/MarginContainer2/SpeedLabel
@onready var speed_arrow = $TopContainer/HBoxContainer/VBoxContainer/MarginContainer/SpeedArrow
@onready var speed_base = $TopContainer/HBoxContainer/VBoxContainer/MarginContainer/SpeedBase
@onready var speed_base_fast = $TopContainer/HBoxContainer/VBoxContainer/MarginContainer/SpeedBaseFast

@onready var score_label = $TopContainer/HBoxContainer/MarginContainer/VBoxContainer2/ScoreLabel
@onready var max_score_label = $TopContainer/HBoxContainer/MarginContainer/VBoxContainer2/MaxScoreLabel

@onready var restart_button = $ButtonsContainer/HBoxContainer/RestartButton
@onready var overlay = $Overlay

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.visible = false
	
	Player.score_updated.connect(update_score)
	Player.max_score_updated.connect(update_max_score)
	
	var safe_area_rect = DisplayServer.get_display_safe_area()
	var safe_area_position = safe_area_rect.position
	if safe_area_position.y > 0:
		$TopContainer.add_theme_constant_override("margin_top", safe_area_position.y)
		$ButtonsContainer.add_theme_constant_override("margin_top", safe_area_position.y)
	
	speed_arrow.pivot_offset = Vector2(100, 100)
	
	score_label.text = "0"
	max_score_label.text = str(Player.max_score)


func _process(_delta: float) -> void:
	update_speed()


func update_speed():
	var velocity = car.velocity.length()
	
	var speed = round(velocity / Player.PIXEL_IN_METER * speed_ratio)
	speed_label.text = str(int(speed))
	
	var gear = car.gear
	var gear_min = car.gear_min_speed[gear]
	var gear_max = car.gear_max_speed[gear]
	var ratio = (velocity - gear_min) / (gear_max - gear_min)
	var gear_limit = lerpf(-90, 90, ratio)
	gear_limit += rng.randf_range(-2, 2)
	
	speed_arrow.rotation_degrees = gear_limit
	
	if gear >= car.max_gear:
		speed_base_fast.visible = true
		speed_base.visible = false
	else:
		speed_base_fast.visible = false
		speed_base.visible = true
		


func update_max_score():
	max_score_label.text = str(Player.max_score)


func update_score():
	score_label.text = str(Player.current_score)


func _on_check_button_toggled(toggled_on: bool) -> void:
	pause.emit(toggled_on)
	restart_button.disabled = !toggled_on
	restart_button.visible = toggled_on
	overlay.visible = toggled_on


func _on_restart_button_pressed() -> void:
	restart.emit()
