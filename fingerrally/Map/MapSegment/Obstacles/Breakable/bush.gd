extends StaticBody2D

var type: int

func _ready() -> void:
	match type:
		1:
			$AnimatedSprite2D.play("b1")
		2:
			$AnimatedSprite2D.play("b2")
		3:
			$AnimatedSprite2D.play("b3")
		_:
			$AnimatedSprite2D.play("b1")

func hit():
	set_collision_layer_value(3, false)
	$AnimatedSprite2D.play("hit")
	await $AnimatedSprite2D.animation_finished
	queue_free()
