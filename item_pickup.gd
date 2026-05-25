extends Area3D

@export var item_id := "scrap"
@export var amount := 1
@export var display_name := ""
@export_multiline var info := ""

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var _picked_up := false

const ITEM_DATA := {
	"wood": {
		"name": "Wood",
		"info": "Resource stack",
		"color": Color(0.55, 0.34, 0.18, 1.0),
	},
	"stone": {
		"name": "Stone",
		"info": "Crafting material",
		"color": Color(0.45, 0.48, 0.47, 1.0),
	},
	"scrap": {
		"name": "Scrap",
		"info": "Recovered metal",
		"color": Color(0.34, 0.48, 0.52, 1.0),
	},
	"ammo": {
		"name": "Ammo",
		"info": "Weapon ammunition",
		"color": Color(0.80, 0.63, 0.22, 1.0),
	},
}

func _ready() -> void:
	add_to_group("pickup_items")

	var mat := StandardMaterial3D.new()
	mat.albedo_color = _item_color().darkened(0.08)
	mat.roughness = 0.85
	mat.metallic = 0.05
	mesh.set_surface_override_material(0, mat)

func set_focused(_focused: bool) -> void:
	pass

func is_pickup_available() -> bool:
	return not _picked_up and not is_queued_for_deletion()

func pickup(player: Node) -> bool:
	if _picked_up:
		return false
	if not player.has_method("add_item"):
		return false
	if not player.add_item(item_id, amount):
		return false
	_picked_up = true
	collision_layer = 0
	collision_mask = 0
	monitorable = false
	monitoring = false
	visible = false
	if collision_shape:
		collision_shape.disabled = true
	queue_free()
	return true

func get_focus_data(camera: Camera3D) -> Dictionary:
	if not is_pickup_available():
		return {}
	return {
		"name": _item_name(),
		"amount": amount,
		"info": _item_info(),
		"screen_rect": _screen_rect(camera),
	}

func _item_name() -> String:
	if not display_name.is_empty():
		return display_name
	if ITEM_DATA.has(item_id):
		return ITEM_DATA[item_id]["name"]
	return item_id.capitalize()

func _item_info() -> String:
	if not info.is_empty():
		return info
	if ITEM_DATA.has(item_id):
		return ITEM_DATA[item_id]["info"]
	return "Item detectat pe jos."

func _item_color() -> Color:
	if ITEM_DATA.has(item_id):
		return ITEM_DATA[item_id]["color"]
	return Color(0.75, 0.75, 0.72, 1.0)

func _screen_rect(camera: Camera3D) -> Rect2:
	var aabb := mesh.get_aabb()
	var corners := [
		Vector3(aabb.position.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.end.x, aabb.position.y, aabb.position.z),
		Vector3(aabb.position.x, aabb.end.y, aabb.position.z),
		Vector3(aabb.end.x, aabb.end.y, aabb.position.z),
		Vector3(aabb.position.x, aabb.position.y, aabb.end.z),
		Vector3(aabb.end.x, aabb.position.y, aabb.end.z),
		Vector3(aabb.position.x, aabb.end.y, aabb.end.z),
		Vector3(aabb.end.x, aabb.end.y, aabb.end.z),
	]

	var has_point := false
	var min_pos := Vector2.INF
	var max_pos := -Vector2.INF
	for corner in corners:
		var world_pos: Vector3 = mesh.global_transform * corner
		if camera.is_position_behind(world_pos):
			continue
		var screen_pos := camera.unproject_position(world_pos)
		min_pos = min_pos.min(screen_pos)
		max_pos = max_pos.max(screen_pos)
		has_point = true

	if not has_point:
		return Rect2()

	var rect := Rect2(min_pos, max_pos - min_pos)
	rect = rect.grow(10.0)
	rect.size.x = max(rect.size.x, 42.0)
	rect.size.y = max(rect.size.y, 32.0)
	return rect
