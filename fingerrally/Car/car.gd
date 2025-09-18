extends CharacterBody2D

class_name Car

# scenes

const track_scene = preload("res://TireTracks/TireTrack.tscn")


# signals

signal hitted
signal died
signal drift_started
signal drift_finished
signal light_hitted
signal engine_on_changed(on)

# nodes

@onready var sprite = $Sprite2D
@onready var l_wheel = $LeftWheel
@onready var r_wheel = $RightWheel
@onready var smoke = $Smoke
@onready var e_smoke = $EngineSmoke
@onready var explosion = $Explosion
@onready var dusts = [$Dust, $Dust2]
@onready var invincibility_timer = $InvincibilityTimer

@onready var fl = $FL
@onready var fr = $FR
@onready var bl = $BL
@onready var br = $BR

# car setup

@export var shadow_offset = 15
@export var invincibility_time = 3

@export var wheel_base = 180  # Distance from front to rear wheel
@export var steering_angle = 25  # Amount that front wheel turns, in degrees

@export var default_engine_power = 1500
@export var max_speed = 225.0
@export var hit_min_speed = 100.0
@export var fast_speed = 180

@export var braking = -450
@export var max_speed_reverse = 250

@export var max_health = 4

# constants

const drag = -0.0015
const min_speed = 5
const friction_increase_speed = 200
const friction_increase_rate = 3
const speed_ratio = 10

const dead_angle_from = 60
const dead_angle_to = 120
const dead_angle_middle = 90
const return_angle_from = -10
const return_angle_to = -170

# context

var surface: Surface
var is_invincible = false
var engine_on = false:
	set(value):
		var new_value = value if health > 0 else false
		if engine_on != new_value:
			engine_on_changed.emit(new_value)
		engine_on = new_value
		smoke.emitting = engine_on
var speed: int:
	get:
		return round(velocity.length() / Player.PIXEL_IN_METER * speed_ratio)
		

# private

var steer_angle
var acceleration = Vector2.ZERO

var _engine_power = 0
var engine_power:
	get:
		return _engine_power if engine_on else 0
	set(value):
		_engine_power = value

var drifting = false:
	set(value):
		if drifting != value:
			if value:
				start_drift()
			else:
				stop_drift()
		drifting = value

var health:
	set(value):
		health = max(value, 0)
		check_health()

var tracks: Array
var tracks_drift: Array

# api

func start():
	engine_on = true

func set_surface(_surface: Surface):
	print(_surface)
	drifting = false
	stop_track()
	surface = _surface
	
	if surface.track_intensity > 0:
		start_track()
	for dust in dusts:
		dust.color = surface.dust_color

# inner

func _ready() -> void:
	invincibility_timer.wait_time = invincibility_time
	engine_power = default_engine_power
	health = max_health
	check_health()
	start_car_vibration()


func _process(_delta: float) -> void:
	$ShadowSprite.global_position = global_position + Vector2(0, shadow_offset)


func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	calculate_steering(delta)
	velocity += acceleration * delta
	handle_collision(move_and_collide(velocity * delta))

func handle_collision(collision: KinematicCollision2D):
	if collision != null:
		var c = collision.get_collider() as CollisionObject2D
		if c != null:
			if c.collision_layer == 2 and speed >= hit_min_speed:
				if is_invincible:
					return
				apply_hit()
				start_invincibility()
			if c.collision_layer == 4:
				if c.has_method("hit"):
					c.hit()
				light_hitted.emit()

func get_input():
	var p = engine_power
	var turn = 0
	if Input.is_action_pressed("steer_right"):
		turn += 1
		p -= engine_power / 2
	if Input.is_action_pressed("steer_left"):
		turn -= 1
		p -= engine_power / 2
	if Input.is_action_just_pressed("accelerate"):
		apply_hit()
	acceleration = transform.x * p

	turn = correct_turn(turn)
	steer_angle = turn * deg_to_rad(steering_angle)
	update_wheels()


func correct_turn(turn: float) -> float:
	var r = rad_to_deg(global_rotation)
	if r > dead_angle_from and r <= dead_angle_middle:
		turn = -1
	elif r < dead_angle_to and r > dead_angle_middle:
		turn = 1
	elif r <= dead_angle_from and r > return_angle_from and turn == 0:
		turn = -1
	elif (r >= dead_angle_to or r < return_angle_to) and turn == 0:
		turn = 1
	return turn

# updates

func start_car_vibration():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.01, 1.01), 0.3)
	await tween.finished
	stop_car_vibration()


func stop_car_vibration():
	var tween = get_tree().create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.3)
	await tween.finished
	start_car_vibration()


func start_drift():
	drift_started.emit()
	var points = [bl, br, fl, fr]
	for point in points:
		var track = track_scene.instantiate()
		add_child(track)
		track.position = point.position
		track.set_intensity(surface.track_drift_intensity)
		track.start()
		tracks_drift.append(track)
	for dust in dusts:
		dust.emitting = true


func stop_drift():
	drift_finished.emit()
	for track in tracks_drift:
		track.stop()
	tracks_drift.clear()
	for dust in dusts:
		dust.emitting = false


func start_track():
	var points = [bl, br, fl, fr]
	for point in points:
		var track = track_scene.instantiate()
		add_child(track)
		track.position = point.position
		track.set_intensity(surface.track_intensity)
		track.start()
		tracks.append(track)


func stop_track():
	for track in tracks:
		track.stop()
	tracks.clear()


func update_wheels():
	var l_tween = get_tree().create_tween()
	l_tween.tween_property(l_wheel, "rotation", steer_angle, 0.2)
	var r_tween = get_tree().create_tween()
	r_tween.tween_property(r_wheel, "rotation", steer_angle, 0.2)


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
		drifting = steer_angle != 0
		traction = surface.traction_fast
	else:
		drifting = false
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.lerp(new_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()


func apply_hit():
	hitted.emit()
	health -= 1

func start_invincibility():
	is_invincible = true
	invincibility_timer.start()

func check_health():
	var health_1 = max_health - 1
	var health_2 = max_health - 2
	match health:
		max_health:
			e_smoke.emitting = false
		health_1:
			e_smoke.emitting = true
			e_smoke.amount = 10
		health_2:
			e_smoke.emitting = true
			e_smoke.amount = 20
		0:
			e_smoke.emitting = false
			explosion.emitting = true
			engine_on = false
			died.emit()
		_:
			e_smoke.emitting = true
			e_smoke.amount = 30


func _on_invincibility_timer_timeout() -> void:
	is_invincible = false
