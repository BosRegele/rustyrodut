extends StaticBody2D

var health := 3

@onready var visual: Polygon2D = $Visual

func hit() -> void:
	health -= 1
	match health:
		2: visual.color = Color(0.85, 0.45, 0.1, 1)
		1: visual.color = Color(0.85, 0.75, 0.1, 1)
		0: queue_free()
