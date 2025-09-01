extends CharacterBody2D

# signals

signal hitted
signal died
signal gear_changed
signal drift_started
signal drift_finished
signal surface_changed

# nodes

@onready var gear_timer = $"GearTimer"
@onready var sprite = $AnimatedSprite2D
@onready var l_wheel = $LeftWheel
@onready var r_wheel = $RightWheel

# car setup

@export var shadow_offset = 15

@export var wheel_base = 180  # Distance from front to rear wheel
@export var steering_angle = 20  # Amount that front wheel turns, in degrees

@export var gear_power = [0, 300, 600, 1100, 1500]
@export var gear_min_speed = [-1, 0, 200, 350, 480]
@export var gear_max_speed = [0, 370, 560, 785, 10000000]

@export var braking = -450
@export var max_speed_reverse = 250
@export var gear_change_time = 0.3

@export var max_health = 0.3

# constants

const drag = -0.0015
const min_speed = 5
const friction_increase_speed = 100
const friction_increase_rate = 3

# context

var surface: Surface
var gear = 0

# private 

var steer_angle
var acceleration = Vector2.ZERO

var engine_power = 0
var next_gear = 0
var is_changing_gear = false
var drifting = false:
	set(value):
		if drifting != value:
			if value:
				drift_started.emit()
			else:
				drift_finished.emit()
		drifting = value

var health

# api

func set_surface(_surface: Surface):
	surface = _surface
	surface_changed.emit()

# inner


func _ready() -> void:
	health = max_health
	check_health()
	gear_timer.wait_time = gear_change_time

func _process(delta: float) -> void:
	$ShadowSprite.global_position = global_position + Vector2(0, shadow_offset)

func _physics_process(delta):
	acceleration = Vector2.ZERO
	check_gear_speed()
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()


func get_input():
	var p = engine_power
	var turn = 0
	if Input.is_action_pressed("steer_right"):
		turn += 1
		p -= engine_power / 2
	if Input.is_action_pressed("steer_left"):
		turn -= 1
		p -= engine_power / 2
	acceleration = transform.x * p
	steer_angle = turn * deg_to_rad(steering_angle)
	update_wheels()


func update_wheels():
	var l_tween = get_tree().create_tween()
	l_tween.tween_property(l_wheel, "rotation", steer_angle, 0.2)
	var r_tween = get_tree().create_tween()
	r_tween.tween_property(r_wheel, "rotation", steer_angle, 0.2)


func check_gear_speed():
	if is_changing_gear:
		return
	var min_speed = gear_min_speed[gear]
	var max_speed = gear_max_speed[gear]
	if velocity.length() < min_speed:
		next_gear = gear - 1
	if velocity.length() >= max_speed:
		next_gear = gear + 1
	if next_gear != gear:
		is_changing_gear = true
		gear_changed.emit()
		engine_power = 0
		gear_timer.start()


func apply_friction():
	if velocity.length() < min_speed:
		velocity = Vector2.ZERO
	
	var drag_force = velocity * velocity.length() * drag
	
	var friction_force = velocity * surface.friction
	if velocity.length() < friction_increase_speed:
		friction_force *= friction_increase_rate
	
	acceleration += drag_force + friction_force


func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = surface.traction_slow
	if velocity.length() > surface.slip_speed:
		traction = surface.traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.lerp(new_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()


func apply_hit():
	hitted.emit()
	health -= 1
	check_health()


func check_health():
	var health_1 = max_health - 1
	var health_2 = max_health - 2
	match health:
		max_health:
			sprite.animation = "full_health"
		health_1:
			sprite.animation = "health-1"
		health_2:
			sprite.animation = "health-2"
		0:
			sprite.animation = "boom"
			await sprite.animation_finished
			died.emit()
		_:
			sprite.animation = "health-3"


func _on_gear_timer_timeout() -> void:
	check_gear()


func check_gear():
	if next_gear != gear:
		gear = next_gear
		check_engine()
		is_changing_gear = false


func check_engine():
	engine_power = gear_power[gear]
