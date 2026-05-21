extends Area2D

const SPEED := 700.0

func _process(delta: float) -> void:
	position += Vector2(cos(rotation), sin(rotation)) * SPEED * delta
	if not get_viewport_rect().grow(200.0).has_point(global_position):
		queue_free()
