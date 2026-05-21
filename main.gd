extends Node2D

const WORLD_W := 3000
const WORLD_H := 2000
const GRID := 80

func _draw() -> void:
	draw_rect(Rect2(0, 0, WORLD_W, WORLD_H), Color(0.08, 0.1, 0.13))
	for x in range(0, WORLD_W + 1, GRID):
		draw_line(Vector2(x, 0), Vector2(x, WORLD_H), Color(0.13, 0.16, 0.2), 1.0)
	for y in range(0, WORLD_H + 1, GRID):
		draw_line(Vector2(0, y), Vector2(WORLD_W, y), Color(0.13, 0.16, 0.2), 1.0)
