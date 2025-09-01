extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Car.set_surface(Surface.surface_for_type(Surface.TYPE.ASPHALT))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
