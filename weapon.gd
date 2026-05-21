extends Node2D

const BULLET = preload("res://bullet.tscn")
const FIRE_RATE := 0.15

var _can_fire := true

@onready var muzzle: Marker2D = $Muzzle
@onready var muzzle_flash: Node2D = $Muzzle/MuzzleFlash

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _can_fire:
		_fire()

func _fire() -> void:
	_can_fire = false

	var bullet := BULLET.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.global_rotation = global_rotation

	muzzle_flash.visible = true
	muzzle_flash.scale = Vector2.ONE * randf_range(0.8, 1.3)
	muzzle_flash.rotation = randf_range(-0.4, 0.4)

	await get_tree().create_timer(0.06).timeout
	muzzle_flash.visible = false

	await get_tree().create_timer(0.09).timeout
	_can_fire = true
