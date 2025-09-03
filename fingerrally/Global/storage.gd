extends Node

var cache: Dictionary = {}

const SAVE_PATH: String = "user://cache.save"

func save_to_cache():
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(cache)
	file.close()

func load_from_cache():
	clear_cache()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var _cache = file.get_var()
		if _cache != null:
			cache = _cache
		file.close()

func set_value(key: String, value):
	cache[key] = value

func get_value(key: String, default_value = null):
	return cache.get(key, default_value)

func clear_cache():
	cache.clear()
