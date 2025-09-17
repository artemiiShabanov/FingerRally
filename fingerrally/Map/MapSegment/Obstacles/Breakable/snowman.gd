extends StaticBody2D

var reversed: bool

func _ready() -> void:
	if reversed:
		$AnimatedSprite2D.play("reversed")
	else:
		$AnimatedSprite2D.play("default")

func hit():
	set_collision_layer_value(3, false)
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()
