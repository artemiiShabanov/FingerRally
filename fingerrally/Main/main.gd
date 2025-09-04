extends Node2D


@onready var car = $Car
@onready var camera = $Car/MainCamera
@onready var hud = $CanvasLayer/Hud

var surface_type: Surface.TYPE
var prev_y = 0

func _ready() -> void:
	SoundPlayer.start_lasting_sound(SoundPlayer.LASTING_SOUND.AMBIENT)
	change_surface(Surface.TYPE.ASPHALT)

func _process(_delta: float) -> void:
	if car.health > 0:
		var pos = -car.global_position.y
		if pos - prev_y > Player.CHECKPOINT_DIFF:
			Player.moved(pos)
			prev_y = pos

func start():
	prev_y = 0
	SoundPlayer.start_lasting_sound(SoundPlayer.LASTING_SOUND.MUSIC)
	car.start()

func finish():
	Player.finish()
	Player.reset()
	SoundPlayer.stop_lasting_sound(SoundPlayer.LASTING_SOUND.MUSIC)

func restart(with_timer: bool):
	finish()
	if with_timer:
		await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()


func change_surface(new_type: Surface.TYPE):
	SoundPlayer.stop_surface_sound(surface_type)
	SoundPlayer.start_surface_sound(new_type)
	surface_type = new_type
	var surface = Surface.surface_for_type(new_type)
	car.set_surface(surface)


func _on_car_hitted() -> void:
	SoundPlayer.play_once_sound(SoundPlayer.ONCE_SOUND.HIT)
	Vibration.vibrate(Vibration.TYPE.HIT)
	camera.apply_shake()


func _on_car_gear_changed(next_gear) -> void:
	#SoundPlayer.play_once_sound(SoundPlayer.ONCE_SOUND.GEAR_CHANGE)
	Vibration.vibrate(Vibration.TYPE.GEAR_CHANGE)
	Player.set_gear(next_gear)

func _on_car_died() -> void:
	restart(true)

func _on_car_engine_on_changed(on: bool) -> void:
	if on:
		SoundPlayer.start_lasting_sound(SoundPlayer.LASTING_SOUND.ENGINE)
	else:
		SoundPlayer.stop_lasting_sound(SoundPlayer.LASTING_SOUND.ENGINE)


func _on_hud_pause(paused: bool) -> void:
	if paused:
		get_tree().paused = true
	else:
		get_tree().paused = false


func _on_car_drift_started() -> void:
		SoundPlayer.start_lasting_sound(SoundPlayer.LASTING_SOUND.DRIFT)


func _on_car_drift_finished() -> void:
	SoundPlayer.stop_lasting_sound(SoundPlayer.LASTING_SOUND.DRIFT)


func _on_hud_restart() -> void:
	get_tree().paused = false
	restart(false)


func _on_hud_counted_down() -> void:
	hud.activate()
	start()


func _on_hud_start_pressed() -> void:
	hud.start_countdown()
