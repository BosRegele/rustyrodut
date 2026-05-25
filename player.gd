extends CharacterBody3D

const SPEED := 5.0
const SPRINT_SPEED := 8.0
const CROUCH_SPEED := 2.8
const CRAWL_SPEED := 1.35
const JUMP_FORCE := 6.0
const GRAVITY := 20.0
const MOUSE_SENS := 0.002
const PICKUP_RANGE := 4.0
const STAND_CAMERA_Y := 0.6
const CROUCH_CAMERA_Y := 0.32
const CRAWL_CAMERA_Y := 0.08
const STAND_COLLIDER_HEIGHT := 1.7
const CROUCH_COLLIDER_HEIGHT := 1.15
const CRAWL_COLLIDER_HEIGHT := 0.85
const STANCE_LERP_SPEED := 12.0

@onready var camera: Camera3D = $Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var interact_ray: RayCast3D = $Camera3D/RayCast3D
@onready var pistol: Node3D = $Camera3D/Weapon
@onready var rifle: Node3D = $Camera3D/Rifle
@onready var inv_hud = $InventoryHUD

var _pitch := 0.0
var _current_slot := 1
var _inventory_open := false
var _focused_item: Node = null
var _stance := "stand"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	interact_ray.collide_with_areas = true
	interact_ray.collide_with_bodies = true
	inv_hud.inventory_open_changed.connect(_on_inventory_open_changed)
	inv_hud.belt_changed.connect(_on_belt_changed)
	_equip(1)

func _equip(slot: int) -> void:
	_current_slot = slot
	var item_id: String = inv_hud.get_belt_item(slot - 1)
	var can_use_weapon := not _inventory_open

	pistol.visible = (item_id == "pistol")
	pistol.process_mode = PROCESS_MODE_INHERIT if item_id == "pistol" and can_use_weapon else PROCESS_MODE_DISABLED
	pistol.get_node("UI").visible = (item_id == "pistol" and can_use_weapon)

	rifle.visible = (item_id == "rifle")
	rifle.process_mode = PROCESS_MODE_INHERIT if item_id == "rifle" and can_use_weapon else PROCESS_MODE_DISABLED
	rifle.get_node("UI").visible = (item_id == "rifle" and can_use_weapon)
	inv_hud.update_active(slot)

func add_item(item_id: String, amount: int = 1) -> bool:
	return inv_hud.add_item(item_id, amount)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_TAB or event.keycode == KEY_I:
			inv_hud.toggle_inventory()
			return

	if event is InputEventMouseMotion and not _inventory_open:
		rotate_y(-event.relative.x * MOUSE_SENS)
		_pitch = clamp(_pitch - event.relative.y * MOUSE_SENS, -1.4, 1.4)
		camera.rotation.x = _pitch
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventKey and event.pressed and not _inventory_open:
		if event.is_action_pressed("interact"):
			_try_pickup_focused_item()
			return
		if event.is_action_pressed("crouch") or event.keycode == KEY_CTRL:
			_toggle_crouch()
			return
		if event.is_action_pressed("crawl") or event.keycode == KEY_Z:
			_toggle_crawl()
			return
		if event.keycode == KEY_1:
			_equip(1)
		elif event.keycode == KEY_2:
			_equip(2)
		elif event.keycode == KEY_3:
			_equip(3)
		elif event.keycode == KEY_4:
			_equip(4)
		elif event.keycode == KEY_5:
			_equip(5)
		elif event.keycode == KEY_6:
			_equip(6)

func _physics_process(delta: float) -> void:
	if _inventory_open:
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		move_and_slide()
		return

	_update_focused_item()
	_update_stance(delta)

	var dir := Vector3.ZERO
	var basis := global_transform.basis

	if Input.is_action_pressed("move_forward"):
		dir -= basis.z
	if Input.is_action_pressed("move_back"):
		dir += basis.z
	if Input.is_action_pressed("move_left"):
		dir -= basis.x
	if Input.is_action_pressed("move_right"):
		dir += basis.x

	dir.y = 0
	dir = dir.normalized()
	var move_speed := _get_move_speed(dir)
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif Input.is_action_just_pressed("jump") and _stance == "stand":
		velocity.y = JUMP_FORCE

	move_and_slide()

func _on_inventory_open_changed(is_open: bool) -> void:
	_inventory_open = is_open
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if is_open else Input.MOUSE_MODE_CAPTURED)
	if is_open:
		_clear_focused_item()
	_equip(_current_slot)

func _on_belt_changed(slot: int) -> void:
	if slot == _current_slot:
		_equip(_current_slot)

func _update_focused_item() -> void:
	if _focused_item and (not is_instance_valid(_focused_item) or _focused_item.is_queued_for_deletion()):
		_focused_item = null
		inv_hud.set_pickup_focus({})

	var next_item: Node = null
	if not _inventory_open:
		interact_ray.force_raycast_update()
		if interact_ray.is_colliding():
			var hit := interact_ray.get_collider()
			var distance := camera.global_position.distance_to(interact_ray.get_collision_point())
			if hit and distance <= PICKUP_RANGE and _can_focus_pickup(hit):
				next_item = hit

	if next_item == _focused_item:
		if _focused_item and _focused_item.has_method("get_focus_data"):
			var focus_data: Dictionary = _focused_item.get_focus_data(camera)
			if focus_data.is_empty():
				_clear_focused_item()
			else:
				inv_hud.set_pickup_focus(focus_data)
		return

	if _focused_item and is_instance_valid(_focused_item):
		_focused_item.set_focused(false)
	_focused_item = next_item
	if _focused_item:
		_focused_item.set_focused(true)
		var focus_data: Dictionary = _focused_item.get_focus_data(camera)
		if focus_data.is_empty():
			_clear_focused_item()
		else:
			inv_hud.set_pickup_focus(focus_data)
	else:
		inv_hud.set_pickup_focus({})

func _try_pickup_focused_item() -> void:
	if _focused_item == null or not is_instance_valid(_focused_item) or _focused_item.is_queued_for_deletion():
		_focused_item = null
		inv_hud.set_pickup_focus({})
		return
	var item := _focused_item
	_clear_focused_item()
	if item.pickup(self):
		_focused_item = null
		inv_hud.set_pickup_focus({})

func _clear_focused_item() -> void:
	if _focused_item and is_instance_valid(_focused_item):
		_focused_item.set_focused(false)
	_focused_item = null
	inv_hud.set_pickup_focus({})

func _can_focus_pickup(hit: Object) -> bool:
	if not hit or hit.is_queued_for_deletion():
		return false
	if not hit.has_method("set_focused") or not hit.has_method("pickup") or not hit.has_method("get_focus_data"):
		return false
	if hit.has_method("is_pickup_available") and not hit.is_pickup_available():
		return false
	return true

func _toggle_crouch() -> void:
	if _stance == "crawl":
		_stance = "crouch"
	elif _stance == "crouch":
		_stance = "stand"
	else:
		_stance = "crouch"

func _toggle_crawl() -> void:
	_stance = "stand" if _stance == "crawl" else "crawl"

func _get_move_speed(dir: Vector3) -> float:
	match _stance:
		"crawl":
			return CRAWL_SPEED
		"crouch":
			return CROUCH_SPEED
		_:
			if Input.is_action_pressed("sprint") and dir.length() > 0.0:
				return SPRINT_SPEED
			return SPEED

func _update_stance(delta: float) -> void:
	var target_camera_y := STAND_CAMERA_Y
	var target_height := STAND_COLLIDER_HEIGHT
	match _stance:
		"crouch":
			target_camera_y = CROUCH_CAMERA_Y
			target_height = CROUCH_COLLIDER_HEIGHT
		"crawl":
			target_camera_y = CRAWL_CAMERA_Y
			target_height = CRAWL_COLLIDER_HEIGHT

	camera.position.y = lerpf(camera.position.y, target_camera_y, min(1.0, delta * STANCE_LERP_SPEED))
	var capsule := collision_shape.shape as CapsuleShape3D
	if capsule:
		capsule.height = lerpf(capsule.height, target_height, min(1.0, delta * STANCE_LERP_SPEED))
