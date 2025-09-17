extends Node

enum ONCE_SOUND {
	COUNTDOWN,
	GEAR_CHANGE,
	HIT,
	LIGHT_HIT
}

var once_sounds = {
	ONCE_SOUND.COUNTDOWN: preload("res://Resourses/Sounds/321.mp3"),
	ONCE_SOUND.GEAR_CHANGE: preload("res://Resourses/Sounds/gear.mp3"),
	ONCE_SOUND.HIT: preload("res://Resourses/Sounds/hit.mp3"),
	ONCE_SOUND.LIGHT_HIT: preload("res://Resourses/Sounds/light_hit.mp3"),
}

enum LASTING_SOUND {
	MUSIC,
	AMBIENT,
	ENGINE,
	DRIFT
}

var lasting_sounds = {
	LASTING_SOUND.MUSIC: preload("res://Resourses/Music/Wild Horizon.mp3"),
	LASTING_SOUND.AMBIENT: preload("res://Resourses/Sounds/ambient.mp3"),
	LASTING_SOUND.ENGINE: preload("res://Resourses/Sounds/engine.mp3"),
	LASTING_SOUND.DRIFT: preload("res://Resourses/Sounds/drift.mp3"),
}

var surface_sounds = {
	Surface.TYPE.ASPHALT: preload("res://Resourses/Music/Wild Horizon.mp3"),
	Surface.TYPE.DIRT: preload("res://Resourses/Music/Wild Horizon.mp3"),
	Surface.TYPE.SAND: preload("res://Resourses/Music/Wild Horizon.mp3"),
	Surface.TYPE.SNOW: preload("res://Resourses/Music/Wild Horizon.mp3"),
	Surface.TYPE.GRAVEL: preload("res://Resourses/Music/Wild Horizon.mp3"),
}

var once_audio_player: AudioStreamPlayer
var lasting_players: Dictionary
var surface_players: Dictionary

func _ready():
	once_audio_player = AudioStreamPlayer.new()
	once_audio_player.volume_db = 20
	add_child(once_audio_player)
	init_lasting_players()
	init_surface_players()

func init_lasting_players():
	for sound in LASTING_SOUND:
		var asp = AudioStreamPlayer.new()
		asp.stream = lasting_sounds[LASTING_SOUND[sound]]
		add_child(asp)
		lasting_players[LASTING_SOUND[sound]] = asp

func init_surface_players():
	for surface in Surface.TYPE:
		var asp = AudioStreamPlayer.new()
		asp.stream = surface_sounds[Surface.TYPE[surface]]
		add_child(asp)
		surface_players[Surface.TYPE[surface]] = asp

func play_once_sound(sound: ONCE_SOUND):
	once_audio_player.stream = once_sounds[sound]
	once_audio_player.play()

func start_surface_sound(surface: Surface.TYPE):
	surface_players[surface].play()
	
func stop_surface_sound(surface: Surface.TYPE):
	surface_players[surface].stop()

func start_lasting_sound(sound: LASTING_SOUND):
	lasting_players[sound].play()
	
func stop_lasting_sound(sound: LASTING_SOUND):
	lasting_players[sound].stop()
