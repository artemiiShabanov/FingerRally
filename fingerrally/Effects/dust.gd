extends GPUParticles2D

@export var color: Color:
	set(value):
		color = value
		process_material.color = color

func _ready() -> void:
	process_material.color = color
