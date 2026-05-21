extends Node3D

const FIRE_RATE := 0.12

var _can_fire := true

@onready var ray: RayCast3D = $"../RayCast3D"
@onready var flash_light: OmniLight3D = $MuzzlePoint/FlashLight
@onready var flash_mesh: MeshInstance3D = $MuzzlePoint/FlashMesh

func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and _can_fire:
		_fire()

func _fire() -> void:
	_can_fire = false

	ray.force_raycast_update()
	if ray.is_colliding():
		var body := ray.get_collider()
		if body.has_method("hit"):
			body.hit()

	flash_light.visible = true
	flash_mesh.visible = true
	flash_light.light_energy = randf_range(2.5, 4.5)
	var s := randf_range(0.8, 1.4)
	flash_mesh.scale = Vector3(s, s, s)

	await get_tree().create_timer(0.06).timeout
	flash_light.visible = false
	flash_mesh.visible = false

	await get_tree().create_timer(0.06).timeout
	_can_fire = true
