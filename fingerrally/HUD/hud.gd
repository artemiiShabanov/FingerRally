extends Control

@export var car: Car

signal pause(paused)
signal restart
signal start_pressed
signal counted_down

enum State {
	COUNTDOWN,
	TAP_TO_START,
	ACTIVE,
	PAUSED
}

const speed_ratio = 10

@onready var speed_label =  $TopContainer/HBoxContainer/VBoxContainer/MarginContainer2/SpeedLabel
@onready var speed_arrow = $TopContainer/HBoxContainer/VBoxContainer/MarginContainer/SpeedArrow
@onready var speed_base = $TopContainer/HBoxContainer/VBoxContainer/MarginContainer/SpeedBase
@onready var speed_base_fast = $TopContainer/HBoxContainer/VBoxContainer/MarginContainer/SpeedBaseFast

@onready var score_label = $TopContainer/HBoxContainer/MarginContainer/VBoxContainer2/ScoreLabel
@onready var max_score_label = $TopContainer/HBoxContainer/MarginContainer/VBoxContainer2/MaxScoreLabel

@onready var pause_button = $ButtonsContainer/HBoxContainer/PauseButton
@onready var restart_button = $ButtonsContainer/HBoxContainer/RestartButton

@onready var countdown_label = $CenterContainer/CountdownLabel
@onready var tap_to_start_label = $CenterContainer/TapToStartLabel

@onready var overlay = $Overlay
@onready var tap_to_start_button = $Overlay/TapToStartButton

@export var state: State = State.TAP_TO_START:
	set(value):
		state = value
		update_for_state()

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	Player.score_updated.connect(update_score)
	Player.max_score_updated.connect(update_max_score)
	
	var safe_area_rect = DisplayServer.get_display_safe_area()
	var safe_area_position = safe_area_rect.position
	if safe_area_position.y > 0:
		$TopContainer.add_theme_constant_override("margin_top", safe_area_position.y)
		$ButtonsContainer.add_theme_constant_override("margin_top", safe_area_position.y)
	
	$CenterContainer.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
	
	speed_arrow.pivot_offset = Vector2(100, 100)
	
	score_label.text = "0"
	max_score_label.text = str(Player.max_score)
	
	overlay.mouse_filter = MouseFilter.MOUSE_FILTER_PASS
	
	update_for_state()


func _process(_delta: float) -> void:
	update_speed()


func start_countdown():
	state = State.COUNTDOWN


func activate():
	state = State.ACTIVE


func reload():
	state = State.TAP_TO_START


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


func update_for_state():
	match state:
		State.ACTIVE:
			restart_button.disabled = true
			restart_button.visible = false
			pause_button.disabled = false
			pause_button.visible = true
			overlay.visible = false
			countdown_label.visible = false
			tap_to_start_label.visible = false
			tap_to_start_button.disabled = true
			tap_to_start_button.visible = false
		State.PAUSED:
			restart_button.disabled = false
			restart_button.visible = true
			pause_button.disabled = false
			pause_button.visible = true
			overlay.visible = true
			countdown_label.visible = false
			tap_to_start_label.visible = false
			tap_to_start_button.disabled = true
			tap_to_start_button.visible = false
		State.TAP_TO_START:
			restart_button.disabled = true
			restart_button.visible = false
			pause_button.disabled = true
			pause_button.visible = false
			overlay.visible = true
			countdown_label.visible = false
			tap_to_start_label.visible = true
			tap_to_start_button.disabled = false
			tap_to_start_button.visible = true
		State.COUNTDOWN:
			restart_button.disabled = true
			restart_button.visible = false
			pause_button.disabled = true
			pause_button.visible = false
			overlay.visible = true
			countdown_label.visible = true
			tap_to_start_label.visible = false
			tap_to_start_button.disabled = true
			tap_to_start_button.visible = false
			countdown()

func countdown():
	SoundPlayer.play_once_sound(SoundPlayer.ONCE_SOUND.COUNTDOWN)
	countdown_label.text = "3"
	await get_tree().create_timer(1).timeout
	countdown_label.text = "2"
	await get_tree().create_timer(1).timeout
	countdown_label.text = "1"
	await get_tree().create_timer(1).timeout
	countdown_label.text = "GO!"
	await get_tree().create_timer(1).timeout
	counted_down.emit()

func update_max_score():
	max_score_label.text = str(Player.max_score)


func update_score():
	score_label.text = str(Player.current_score)


func _on_check_button_toggled(toggled_on: bool) -> void:
	pause.emit(toggled_on)
	state = State.PAUSED if toggled_on else State.ACTIVE


func _on_restart_button_pressed() -> void:
	restart.emit()


func _on_button_pressed() -> void:
	start_pressed.emit()
