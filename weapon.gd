extends Node3D

const FIRE_RATE := 0.3
const BULLET_SCENE = preload("res://bullet.tscn")

var _can_fire := true

var max_mag_size := 6
var current_ammo := 6
var total_ammo := 30
var is_reloading := false

@onready var muzzle: Marker3D = $MuzzlePoint
@onready var ray: RayCast3D = $"../RayCast3D"
@onready var fire_sound: AudioStreamPlayer3D = $FireSound
@onready var empty_sound: AudioStreamPlayer3D = $EmptySound
@onready var reload_sound: AudioStreamPlayer3D = $ReloadSound
@onready var ammo_label: Label = $UI/AmmoLabel
@onready var flash_light: OmniLight3D = $MuzzlePoint/FlashLight
@onready var flash_mesh: MeshInstance3D = $MuzzlePoint/FlashMesh

func _ready() -> void:
	fire_sound.volume_db = -8.0
	_update_ammo_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_reloading: return
		
		if current_ammo > 0:
			if _can_fire: _fire()
		else:
			_empty_fire()
	
	if event is InputEventKey and event.keycode == KEY_R and event.pressed:
		if not is_reloading and current_ammo < max_mag_size and total_ammo > 0:
			_reload()

func _fire() -> void:
	_can_fire = false
	current_ammo -= 1
	_update_ammo_ui()
	if not fire_sound.playing:
		fire_sound.play()

	# Gaseste punctul tinta din centrul crosshair-ului
	ray.force_raycast_update()
	var aim_point: Vector3
	if ray.is_colliding():
		aim_point = ray.get_collision_point()
	else:
		aim_point = ray.global_position + (-ray.global_transform.basis.z * 300.0)

	# Spawneaza glontul din muzzle, indreptat spre tinta
	var bullet := BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = muzzle.global_position
	var direction := (aim_point - muzzle.global_position).normalized()
	bullet.look_at(muzzle.global_position + direction)
	bullet.linear_velocity = direction * 150.0

	flash_light.visible = true
	flash_mesh.visible = true
	flash_light.light_energy = randf_range(2.5, 4.5)
	var s := randf_range(0.8, 1.4)
	flash_mesh.scale = Vector3(s, s, s)
	await get_tree().create_timer(0.06).timeout
	flash_light.visible = false
	flash_mesh.visible = false

	await get_tree().create_timer(FIRE_RATE - 0.06).timeout
	_can_fire = true

# Această funcție lipsea sau era prost indentată:
func _empty_fire() -> void:
	if not _can_fire: return
	_can_fire = false
	empty_sound.play()
	await get_tree().create_timer(0.3).timeout
	_can_fire = true

func _reload() -> void:
	is_reloading = true
	reload_sound.play()
	await get_tree().create_timer(2.0).timeout 
	var needed = max_mag_size - current_ammo
	var to_reload = min(needed, total_ammo)
	current_ammo += to_reload
	total_ammo -= to_reload
	is_reloading = false
	_update_ammo_ui()

func _update_ammo_ui() -> void:
	if ammo_label:
		ammo_label.text = str(current_ammo) + " / " + str(total_ammo)
