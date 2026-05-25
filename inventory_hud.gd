extends CanvasLayer

signal belt_changed(slot: int)
signal inventory_open_changed(is_open: bool)

class FocusOverlay:
	extends Control

	var focus_data := {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func set_focus_data(data: Dictionary) -> void:
		focus_data = data
		visible = not data.is_empty()
		queue_redraw()

	func _draw() -> void:
		if focus_data.is_empty():
			return

		var rect: Rect2 = focus_data["screen_rect"]
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			return

		var accent := Color(1.0, 0.08, 0.08, 0.96)
		var accent_soft := Color(1.0, 0.03, 0.03, 0.16)
		var ink := Color(0.94, 0.94, 0.92, 0.96)
		var muted := Color(0.78, 0.78, 0.75, 0.92)
		var shadow := Color(0.0, 0.0, 0.0, 0.55)
		var font: Font = get_theme_default_font()

		var corner: float = min(22.0, min(rect.size.x, rect.size.y) * 0.34)
		_draw_corner_box(rect, accent, accent_soft, corner)

		var panel_size := Vector2(260.0, 92.0)
		var panel_pos := Vector2(rect.end.x + 46.0, rect.position.y - 8.0)
		if panel_pos.x + panel_size.x > size.x - 24.0:
			panel_pos.x = rect.position.x - panel_size.x - 46.0
		panel_pos.x = clamp(panel_pos.x, 24.0, max(24.0, size.x - panel_size.x - 24.0))
		panel_pos.y = clamp(panel_pos.y, 64.0, max(64.0, size.y - panel_size.y - 124.0))

		var panel_rect := Rect2(panel_pos, panel_size)
		var anchor := Vector2(rect.end.x, rect.position.y + rect.size.y * 0.46)
		var target := Vector2(panel_rect.position.x, panel_rect.position.y + 29.0)
		if panel_rect.position.x < rect.position.x:
			target.x = panel_rect.end.x
		draw_line(anchor + Vector2(1, 1), target + Vector2(1, 1), shadow, 3.0)
		draw_line(anchor, target, accent, 2.0)

		draw_rect(panel_rect.grow(2.0), Color(0.0, 0.0, 0.0, 0.30), true)
		draw_rect(panel_rect, Color(0.025, 0.026, 0.028, 0.88), true)
		draw_rect(Rect2(panel_rect.position, Vector2(3.0, panel_rect.size.y)), accent, true)
		draw_rect(panel_rect, Color(1.0, 1.0, 1.0, 0.10), false, 1.0)

		var title := "%s  x%d" % [focus_data["name"], focus_data["amount"]]
		var text_origin := panel_rect.position + Vector2(14.0, 25.0)
		_draw_text(font, text_origin, title, 18, ink, shadow, 222.0)
		_draw_text(font, text_origin + Vector2(0, 24), focus_data["info"], 13, muted, shadow, 226.0)
		_draw_text(font, text_origin + Vector2(0, 52), "[E] Pick up", 14, accent, shadow, 160.0)

	func _draw_corner_box(rect: Rect2, accent: Color, fill: Color, corner: float) -> void:
		draw_rect(rect, fill, true)
		draw_line(rect.position, rect.position + Vector2(corner, 0), accent, 2.5)
		draw_line(rect.position, rect.position + Vector2(0, corner), accent, 2.5)
		draw_line(Vector2(rect.end.x, rect.position.y), Vector2(rect.end.x - corner, rect.position.y), accent, 2.5)
		draw_line(Vector2(rect.end.x, rect.position.y), Vector2(rect.end.x, rect.position.y + corner), accent, 2.5)
		draw_line(Vector2(rect.position.x, rect.end.y), Vector2(rect.position.x + corner, rect.end.y), accent, 2.5)
		draw_line(Vector2(rect.position.x, rect.end.y), Vector2(rect.position.x, rect.end.y - corner), accent, 2.5)
		draw_line(rect.end, rect.end - Vector2(corner, 0), accent, 2.5)
		draw_line(rect.end, rect.end - Vector2(0, corner), accent, 2.5)

	func _draw_text(font: Font, pos: Vector2, text: String, font_size: int, color: Color, shadow: Color, width: float) -> void:
		draw_string(font, pos + Vector2(1, 1), text, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, shadow)
		draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, width, font_size, color)

const SLOT_SIZE := Vector2(74, 74)
const SLOT_GAP := 8
const BELT_SLOTS := 6
const BAG_SLOTS := 18
const STACK_LIMIT := 99
const DRAG_START_DISTANCE := 8.0

const COL_BG := Color(0.025, 0.026, 0.030, 0.95)
const COL_SLOT := Color(0.060, 0.064, 0.070, 0.90)
const COL_SLOT_ACTIVE := Color(0.16, 0.055, 0.055, 0.96)
const COL_BORDER := Color(0.25, 0.25, 0.25, 0.72)
const COL_ACTIVE := Color(1.00, 0.08, 0.08, 1.00)
const COL_TEXT := Color(0.92, 0.92, 0.90, 1.00)
const COL_MUTED := Color(0.62, 0.62, 0.60, 1.00)

const ITEMS := {
	"pistol": {
		"name": "Pistol",
		"short": "PST",
		"color": Color(0.72, 0.74, 0.78, 1.0),
		"icon": "res://icon_pistol.png",
		"equip": true,
	},
	"rifle": {
		"name": "Rifle",
		"short": "RFL",
		"color": Color(0.60, 0.36, 0.22, 1.0),
		"icon": "res://icon_rifle.png",
		"equip": true,
	},
	"wood": {
		"name": "Wood",
		"short": "WD",
		"color": Color(0.55, 0.34, 0.18, 1.0),
		"equip": false,
	},
	"stone": {
		"name": "Stone",
		"short": "STN",
		"color": Color(0.45, 0.48, 0.47, 1.0),
		"equip": false,
	},
	"scrap": {
		"name": "Scrap",
		"short": "SCR",
		"color": Color(0.34, 0.48, 0.52, 1.0),
		"equip": false,
	},
	"ammo": {
		"name": "Ammo",
		"short": "AMM",
		"color": Color(0.80, 0.63, 0.22, 1.0),
		"equip": false,
	},
}

var _bag: Array = []
var _belt: Array = []
var _bag_slots: Array[Panel] = []
var _belt_slots: Array[Panel] = []
var _inventory_belt_slots: Array[Panel] = []
var _inventory_panel: Control
var _preview_panel: Panel
var _preview_icon: Panel
var _preview_title: Label
var _preview_type: Label
var _preview_info: Label
var _preview_amount: Label
var _crosshair: Control
var _focus_overlay: FocusOverlay
var _drag_preview: Panel
var _carried := {}
var _pending_drag_stack := {}
var _pending_drag_type := ""
var _pending_drag_index := -1
var _pending_drag_mouse := Vector2.ZERO
var _drag_source_type := ""
var _drag_source_index := -1
var _drop_target_type := ""
var _drop_target_index := -1
var _hover_type := ""
var _hover_index := -1
var _selected_type := ""
var _selected_index := -1
var _selected_stack := {}
var _active_slot := 1
var _is_open := false

func _ready() -> void:
	layer = 20
	_bag.resize(BAG_SLOTS)
	_belt.resize(BELT_SLOTS)
	for i in range(BAG_SLOTS):
		_bag[i] = {}
	for i in range(BELT_SLOTS):
		_belt[i] = {}
	_belt[0] = _make_stack("pistol", 1)
	_belt[1] = _make_stack("rifle", 1)

	_ensure_icons()
	_build()
	set_inventory_open(false)
	update_active(1)

func _process(_delta: float) -> void:
	if not _carried.is_empty():
		_drag_preview.global_position = get_viewport().get_mouse_position() - (_drag_preview.size * 0.5)
		_update_drop_target()
	elif not _pending_drag_stack.is_empty():
		if get_viewport().get_mouse_position().distance_to(_pending_drag_mouse) >= DRAG_START_DISTANCE:
			_start_drag_from_pending()
	else:
		_update_hover_slot()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if not _carried.is_empty():
			_drop_carried_at_mouse()
		elif not _pending_drag_stack.is_empty():
			_finish_click_select()

func add_item(item_id: String, amount: int = 1) -> bool:
	if not ITEMS.has(item_id) or amount <= 0:
		return false

	var remaining := amount
	remaining = _add_to_existing(_bag, item_id, remaining)
	remaining = _add_to_empty(_bag, item_id, remaining)
	if remaining > 0:
		remaining = _add_to_existing(_belt, item_id, remaining)
		remaining = _add_to_empty(_belt, item_id, remaining)

	_refresh_all()
	return remaining == 0

func get_belt_item(slot: int) -> String:
	if slot < 0 or slot >= _belt.size() or _belt[slot].is_empty():
		return ""
	return _belt[slot]["id"]

func is_inventory_open() -> bool:
	return _is_open

func set_inventory_open(open: bool) -> void:
	_is_open = open
	_inventory_panel.visible = open
	_crosshair.visible = not open
	if open:
		set_pickup_focus({})
		if _selected_stack.is_empty():
			_select_first_visible_item()
	else:
		if not _carried.is_empty():
			_cancel_drag()
	_drag_preview.visible = open and not _carried.is_empty()
	for slot in _belt_slots:
		slot.mouse_filter = Control.MOUSE_FILTER_STOP if open else Control.MOUSE_FILTER_IGNORE
	if not open:
		_clear_pending_drag()
		_clear_hover_slot()
	inventory_open_changed.emit(open)

func toggle_inventory() -> void:
	set_inventory_open(not _is_open)

func set_pickup_focus(data: Dictionary) -> void:
	if _focus_overlay:
		_focus_overlay.set_focus_data(data)

func update_active(slot: int) -> void:
	_active_slot = slot
	_refresh_belt()

func _add_to_existing(slots: Array, item_id: String, amount: int) -> int:
	var remaining := amount
	for i in range(slots.size()):
		var stack: Dictionary = slots[i]
		if stack.is_empty() or stack["id"] != item_id:
			continue
		var free_space: int = STACK_LIMIT - stack["amount"]
		if free_space <= 0:
			continue
		var moved: int = min(free_space, remaining)
		stack["amount"] += moved
		slots[i] = stack
		remaining -= moved
		if remaining <= 0:
			return 0
	return remaining

func _add_to_empty(slots: Array, item_id: String, amount: int) -> int:
	var remaining := amount
	for i in range(slots.size()):
		if not slots[i].is_empty():
			continue
		var moved: int = min(STACK_LIMIT, remaining)
		slots[i] = _make_stack(item_id, moved)
		remaining -= moved
		if remaining <= 0:
			return 0
	return remaining

func _make_stack(item_id: String, amount: int) -> Dictionary:
	return {"id": item_id, "amount": amount}

func _build() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_crosshair = Control.new()
	_crosshair.name = "Crosshair"
	_crosshair.set_anchors_preset(Control.PRESET_CENTER)
	_crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_crosshair)

	var cross_color := Color(0.96, 0.96, 0.92, 0.90)
	var cross_shadow := Color(0.0, 0.0, 0.0, 0.60)
	_add_crosshair_line(_crosshair, Rect2(-2, -2, 4, 4), cross_shadow)
	_add_crosshair_line(_crosshair, Rect2(-1, -1, 2, 2), cross_color)

	_focus_overlay = FocusOverlay.new()
	_focus_overlay.name = "FocusOverlay"
	_focus_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(_focus_overlay)
	_focus_overlay.set_focus_data({})

	var belt := HBoxContainer.new()
	belt.name = "Belt"
	belt.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	var belt_width := BELT_SLOTS * SLOT_SIZE.x + (BELT_SLOTS - 1) * SLOT_GAP
	belt.offset_left = -belt_width / 2.0
	belt.offset_right = belt_width / 2.0
	belt.offset_top = -98
	belt.offset_bottom = -24
	belt.add_theme_constant_override("separation", SLOT_GAP)
	root.add_child(belt)

	for i in range(BELT_SLOTS):
		var slot := _make_slot("belt", i)
		belt.add_child(slot)
		_belt_slots.append(slot)

	_inventory_panel = Panel.new()
	_inventory_panel.name = "Inventory"
	_inventory_panel.set_anchors_preset(Control.PRESET_CENTER)
	_inventory_panel.custom_minimum_size = Vector2(810, 470)
	_inventory_panel.offset_left = -405
	_inventory_panel.offset_right = 405
	_inventory_panel.offset_top = -255
	_inventory_panel.offset_bottom = 215
	_inventory_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = COL_BG
	panel_style.border_color = Color(0.18, 0.05, 0.05, 0.95)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.35)
	panel_style.shadow_size = 18
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(6)
	_inventory_panel.add_theme_stylebox_override("panel", panel_style)
	root.add_child(_inventory_panel)

	var title := Label.new()
	title.text = "Inventory"
	title.offset_left = 22
	title.offset_top = 18
	title.offset_right = 300
	title.offset_bottom = 48
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", COL_TEXT)
	_inventory_panel.add_child(title)

	var belt_title := Label.new()
	belt_title.text = "Belt"
	belt_title.offset_left = 22
	belt_title.offset_top = 64
	belt_title.offset_right = 180
	belt_title.offset_bottom = 88
	belt_title.add_theme_font_size_override("font_size", 14)
	belt_title.add_theme_color_override("font_color", COL_MUTED)
	_inventory_panel.add_child(belt_title)

	var belt_grid := GridContainer.new()
	belt_grid.columns = BELT_SLOTS
	belt_grid.offset_left = 22
	belt_grid.offset_top = 92
	belt_grid.offset_right = 500
	belt_grid.offset_bottom = 170
	belt_grid.add_theme_constant_override("h_separation", SLOT_GAP)
	_inventory_panel.add_child(belt_grid)

	for i in range(BELT_SLOTS):
		var slot := _make_slot("belt", i)
		belt_grid.add_child(slot)
		_inventory_belt_slots.append(slot)

	var bag_title := Label.new()
	bag_title.text = "Backpack"
	bag_title.offset_left = 22
	bag_title.offset_top = 188
	bag_title.offset_right = 180
	bag_title.offset_bottom = 212
	bag_title.add_theme_font_size_override("font_size", 14)
	bag_title.add_theme_color_override("font_color", COL_MUTED)
	_inventory_panel.add_child(bag_title)

	var bag_grid := GridContainer.new()
	bag_grid.columns = 6
	bag_grid.offset_left = 22
	bag_grid.offset_top = 216
	bag_grid.offset_right = 500
	bag_grid.offset_bottom = 456
	bag_grid.add_theme_constant_override("h_separation", SLOT_GAP)
	bag_grid.add_theme_constant_override("v_separation", SLOT_GAP)
	_inventory_panel.add_child(bag_grid)

	for i in range(BAG_SLOTS):
		var slot := _make_slot("bag", i)
		bag_grid.add_child(slot)
		_bag_slots.append(slot)

	_build_preview_panel()

	_drag_preview = _make_item_panel()
	_drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_drag_preview.visible = false
	root.add_child(_drag_preview)

	_refresh_all()

func _make_slot(slot_type: String, index: int) -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = SLOT_SIZE
	p.mouse_filter = Control.MOUSE_FILTER_STOP
	p.set_meta("slot_type", slot_type)
	p.set_meta("slot_index", index)
	p.gui_input.connect(_on_slot_input.bind(p))
	var style := StyleBoxFlat.new()
	style.bg_color = COL_SLOT
	style.border_color = COL_BORDER
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.22)
	style.shadow_size = 4
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	p.add_theme_stylebox_override("panel", style)

	var key := Label.new()
	key.name = "Key"
	key.text = str(index + 1) if slot_type == "belt" else ""
	key.offset_left = 5
	key.offset_top = 3
	key.offset_right = 28
	key.offset_bottom = 20
	key.add_theme_font_size_override("font_size", 11)
	key.add_theme_color_override("font_color", COL_MUTED)
	p.add_child(key)

	var item := _make_item_panel()
	item.name = "Item"
	item.visible = false
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(item)
	return p

func _build_preview_panel() -> void:
	_preview_panel = Panel.new()
	_preview_panel.name = "ItemPreview"
	_preview_panel.offset_left = 540
	_preview_panel.offset_top = 92
	_preview_panel.offset_right = 785
	_preview_panel.offset_bottom = 438
	_preview_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.015, 0.016, 0.018, 0.92)
	style.border_color = Color(0.38, 0.02, 0.02, 0.85)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	style.shadow_size = 8
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	_preview_panel.add_theme_stylebox_override("panel", style)
	_inventory_panel.add_child(_preview_panel)

	_preview_icon = _make_item_panel()
	_preview_icon.name = "PreviewIcon"
	_preview_icon.position = Vector2(78, 26)
	_preview_icon.custom_minimum_size = Vector2(88, 88)
	_preview_icon.size = Vector2(88, 88)
	_preview_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_preview_panel.add_child(_preview_icon)

	_preview_title = _make_preview_label(Vector2(16, 144), 213, 24, 20, COL_TEXT)
	_preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_panel.add_child(_preview_title)

	_preview_type = _make_preview_label(Vector2(16, 174), 213, 22, 13, COL_ACTIVE)
	_preview_type.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_preview_panel.add_child(_preview_type)

	_preview_amount = _make_preview_label(Vector2(16, 216), 213, 24, 15, COL_TEXT)
	_preview_panel.add_child(_preview_amount)

	_preview_info = _make_preview_label(Vector2(16, 252), 213, 78, 13, COL_MUTED)
	_preview_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_preview_panel.add_child(_preview_info)

	_set_preview({})

func _make_preview_label(pos: Vector2, width: float, height: float, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = pos
	label.size = Vector2(width, height)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _add_crosshair_line(parent: Control, rect: Rect2, color: Color) -> void:
	var line := ColorRect.new()
	line.color = color
	line.offset_left = rect.position.x
	line.offset_top = rect.position.y
	line.offset_right = rect.position.x + rect.size.x
	line.offset_bottom = rect.position.y + rect.size.y
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(line)

func _make_item_panel() -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = SLOT_SIZE
	p.size = SLOT_SIZE
	p.offset_left = 0
	p.offset_top = 0
	p.offset_right = SLOT_SIZE.x
	p.offset_bottom = SLOT_SIZE.y
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.18, 0.19, 0.18, 0.96)
	style.border_color = Color(0.05, 0.05, 0.05, 0.65)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	p.add_theme_stylebox_override("panel", style)

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 8
	icon.offset_top = 8
	icon.offset_right = -8
	icon.offset_bottom = -20
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	p.add_child(icon)

	var tag := Label.new()
	tag.name = "Tag"
	tag.set_anchors_preset(Control.PRESET_FULL_RECT)
	tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tag.add_theme_font_size_override("font_size", 17)
	tag.add_theme_color_override("font_color", Color.WHITE)
	p.add_child(tag)

	var amount := Label.new()
	amount.name = "Amount"
	amount.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	amount.offset_left = -40
	amount.offset_top = -20
	amount.offset_right = -5
	amount.offset_bottom = -3
	amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount.add_theme_font_size_override("font_size", 13)
	amount.add_theme_color_override("font_color", COL_TEXT)
	p.add_child(amount)
	return p

func _on_slot_input(event: InputEvent, slot_panel: Panel) -> void:
	if not _is_open:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		slot_panel.accept_event()
		var slot_type: String = slot_panel.get_meta("slot_type")
		var index: int = slot_panel.get_meta("slot_index")
		if event.pressed:
			_press_slot(slot_type, index)

func _press_slot(slot_type: String, index: int) -> void:
	var slots := _belt if slot_type == "belt" else _bag
	var clicked: Dictionary = slots[index]
	if not clicked.is_empty():
		_set_preview(clicked)
		_selected_type = slot_type
		_selected_index = index
		_refresh_all()

	if clicked.is_empty() or not _carried.is_empty():
		return

	_pending_drag_stack = clicked
	_pending_drag_type = slot_type
	_pending_drag_index = index
	_pending_drag_mouse = get_viewport().get_mouse_position()

func _start_drag_from_pending() -> void:
	if _pending_drag_stack.is_empty():
		return

	var slots := _belt if _pending_drag_type == "belt" else _bag
	_drag_source_type = _pending_drag_type
	_drag_source_index = _pending_drag_index
	_carried = _pending_drag_stack
	slots[_pending_drag_index] = {}
	_clear_pending_drag()
	_clear_hover_slot()
	_update_drop_target()
	_refresh_all()
	if _drag_source_type == "belt":
		belt_changed.emit(_active_slot)

func _finish_click_select() -> void:
	_set_preview(_pending_drag_stack)
	_clear_pending_drag()
	_refresh_all()

func _clear_pending_drag() -> void:
	_pending_drag_stack = {}
	_pending_drag_type = ""
	_pending_drag_index = -1
	_pending_drag_mouse = Vector2.ZERO

func _drop_carried_at_mouse() -> void:
	if _carried.is_empty():
		return

	var target := _slot_at_mouse(get_viewport().get_mouse_position())
	if target.is_empty():
		_cancel_drag()
		return

	_release_slot(target["type"], target["index"])

func _release_slot(slot_type: String, index: int) -> void:
	if _carried.is_empty():
		return

	var source_was_belt := _drag_source_type == "belt"
	if slot_type == _drag_source_type and index == _drag_source_index:
		_cancel_drag()
		return

	var slots := _belt if slot_type == "belt" else _bag
	var clicked: Dictionary = slots[index]

	if clicked.is_empty():
		slots[index] = _carried
		_carried = {}
	elif clicked["id"] == _carried["id"] and clicked["amount"] < STACK_LIMIT:
		var moved: int = min(STACK_LIMIT - clicked["amount"], _carried["amount"])
		clicked["amount"] += moved
		_carried["amount"] -= moved
		slots[index] = clicked
		if _carried["amount"] <= 0:
			_carried = {}
	else:
		slots[index] = _carried
		_return_to_source(clicked)
		_carried = {}

	_clear_drag_source()
	_clear_drop_target()
	_clear_hover_slot()
	_refresh_all()
	if slot_type == "belt" or source_was_belt:
		belt_changed.emit(_active_slot)

func _slot_at_mouse(mouse_pos: Vector2) -> Dictionary:
	for i in range(_inventory_belt_slots.size()):
		if _inventory_belt_slots[i].get_global_rect().has_point(mouse_pos):
			return {"type": "belt", "index": i}
	for i in range(_bag_slots.size()):
		if _bag_slots[i].get_global_rect().has_point(mouse_pos):
			return {"type": "bag", "index": i}
	for i in range(_belt_slots.size()):
		if _belt_slots[i].get_global_rect().has_point(mouse_pos):
			return {"type": "belt", "index": i}
	return {}

func _cancel_drag() -> void:
	var source_was_belt := _drag_source_type == "belt"
	_return_to_source(_carried)
	_carried = {}
	_clear_drag_source()
	_clear_drop_target()
	_clear_hover_slot()
	_refresh_all()
	if source_was_belt:
		belt_changed.emit(_active_slot)

func _return_to_source(stack: Dictionary) -> void:
	if stack.is_empty() or _drag_source_index < 0:
		return
	var source_slots := _belt if _drag_source_type == "belt" else _bag
	source_slots[_drag_source_index] = stack

func _clear_drag_source() -> void:
	_drag_source_type = ""
	_drag_source_index = -1

func _update_drop_target() -> void:
	var target := _slot_at_mouse(get_viewport().get_mouse_position())
	var next_type := ""
	var next_index := -1
	if not target.is_empty():
		next_type = target["type"]
		next_index = target["index"]
	if next_type == _drag_source_type and next_index == _drag_source_index:
		next_type = ""
		next_index = -1
	if next_type == _drop_target_type and next_index == _drop_target_index:
		return
	_drop_target_type = next_type
	_drop_target_index = next_index
	_refresh_all()

func _clear_drop_target() -> void:
	_drop_target_type = ""
	_drop_target_index = -1

func _update_hover_slot() -> void:
	if not _is_open:
		return
	var target := _slot_at_mouse(get_viewport().get_mouse_position())
	var next_type := ""
	var next_index := -1
	if not target.is_empty():
		var slots := _belt if target["type"] == "belt" else _bag
		if not slots[target["index"]].is_empty():
			next_type = target["type"]
			next_index = target["index"]
	if next_type == _hover_type and next_index == _hover_index:
		return
	_hover_type = next_type
	_hover_index = next_index
	_refresh_all()

func _clear_hover_slot() -> void:
	_hover_type = ""
	_hover_index = -1

func _refresh_all() -> void:
	_clear_selected_slot_if_empty()
	_refresh_belt()
	for i in range(_bag_slots.size()):
		_draw_stack(_bag_slots[i], _bag[i], false, "bag", i)
	_draw_stack(_drag_preview, _carried, false)
	_drag_preview.visible = _is_open and not _carried.is_empty()
	if _selected_stack.is_empty():
		_select_first_visible_item()

func _refresh_belt() -> void:
	for i in range(_belt_slots.size()):
		_draw_stack(_belt_slots[i], _belt[i], i + 1 == _active_slot and not _is_open, "belt", i)
	for i in range(_inventory_belt_slots.size()):
		_draw_stack(_inventory_belt_slots[i], _belt[i], false, "belt", i)

func _draw_stack(slot_panel: Panel, stack: Dictionary, active: bool, slot_type := "", index := -1) -> void:
	var is_drop_target := not _carried.is_empty() and slot_type == _drop_target_type and index == _drop_target_index
	var is_hovered := _carried.is_empty() and slot_type == _hover_type and index == _hover_index
	var is_selected := _carried.is_empty() and slot_type == _selected_type and index == _selected_index
	var style := slot_panel.get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		if is_drop_target:
			style.bg_color = Color(0.18, 0.025, 0.025, 0.96)
			style.border_color = COL_ACTIVE
			style.set_border_width_all(2)
		elif is_selected:
			style.bg_color = Color(0.16, 0.028, 0.032, 0.96)
			style.border_color = COL_ACTIVE
			style.set_border_width_all(2)
		elif is_hovered:
			style.bg_color = Color(0.11, 0.035, 0.040, 0.94)
			style.border_color = COL_ACTIVE
			style.set_border_width_all(1)
		else:
			style.bg_color = COL_SLOT_ACTIVE if active else COL_SLOT
			style.border_color = COL_ACTIVE if active else COL_BORDER
			style.set_border_width_all(1)

	var item_panel := slot_panel.get_node_or_null("Item") as Panel
	if item_panel == null:
		item_panel = slot_panel

	var draw_stack := _carried if is_drop_target else stack
	item_panel.visible = not draw_stack.is_empty()
	if draw_stack.is_empty():
		return

	var item_data: Dictionary = ITEMS[draw_stack["id"]]
	var item_style := item_panel.get_theme_stylebox("panel") as StyleBoxFlat
	if item_style:
		item_style.bg_color = Color(0.34, 0.03, 0.03, 0.92) if is_drop_target else item_data["color"].darkened(0.25)
		item_style.border_color = COL_ACTIVE if is_drop_target else Color(0.05, 0.05, 0.05, 0.65)

	var icon := item_panel.get_node_or_null("Icon") as TextureRect
	var tag := item_panel.get_node_or_null("Tag") as Label
	if icon:
		icon.texture = null
		icon.visible = false
	if tag:
		tag.text = item_data["short"]
		tag.visible = true

	if item_data.has("icon") and ResourceLoader.exists(item_data["icon"]):
		if icon:
			icon.texture = load(item_data["icon"])
			icon.visible = true
		if tag:
			tag.visible = false

	var amount := item_panel.get_node_or_null("Amount") as Label
	if amount:
		amount.text = str(draw_stack["amount"]) if draw_stack["amount"] > 1 else ""

func _set_preview(stack: Dictionary) -> void:
	_selected_stack = stack.duplicate()
	if _preview_panel == null:
		return

	if stack.is_empty():
		_preview_panel.visible = false
		return

	_preview_panel.visible = true
	var item_data: Dictionary = ITEMS[stack["id"]]
	_draw_stack(_preview_icon, stack, false)
	_preview_title.text = item_data["name"]
	_preview_type.text = "Inventory item"
	_preview_amount.text = "Amount: %d" % stack["amount"]
	_preview_info.text = _item_info(stack["id"])

func _clear_selected_slot_if_empty() -> void:
	if _selected_index < 0:
		return
	var slots := _belt if _selected_type == "belt" else _bag
	if _selected_index >= slots.size() or slots[_selected_index].is_empty():
		_selected_type = ""
		_selected_index = -1

func _select_first_visible_item() -> void:
	for i in range(_belt.size()):
		if not _belt[i].is_empty():
			_selected_type = "belt"
			_selected_index = i
			_set_preview(_belt[i])
			return
	for i in range(_bag.size()):
		if not _bag[i].is_empty():
			_selected_type = "bag"
			_selected_index = i
			_set_preview(_bag[i])
			return
	_selected_type = ""
	_selected_index = -1
	_set_preview({})

func _item_info(item_id: String) -> String:
	match item_id:
		"pistol":
			return "Sidearm. Can be placed on the belt and equipped from its slot."
		"rifle":
			return "Primary weapon. Move it to any belt slot to equip it there."
		"wood":
			return "Basic resource used for building and crafting."
		"stone":
			return "Heavy resource used for upgrades and crafting."
		"scrap":
			return "Recovered metal used as a valuable crafting material."
		"ammo":
			return "Ammunition stack stored in your backpack."
	return "General inventory item."

func _ensure_icons() -> void:
	var pistol_path := ProjectSettings.globalize_path("res://icon_pistol.png")
	var rifle_path := ProjectSettings.globalize_path("res://icon_rifle.png")
	if not FileAccess.file_exists(pistol_path):
		_gen_pistol().save_png(pistol_path)
	if not FileAccess.file_exists(rifle_path):
		_gen_rifle().save_png(rifle_path)

func _fill(img: Image, x1: int, y1: int, x2: int, y2: int, c: Color) -> void:
	for py in range(max(0, y1), min(img.get_height(), y2)):
		for px in range(max(0, x1), min(img.get_width(), x2)):
			img.set_pixel(px, py, c)

func _gen_pistol() -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_fill(img, 36, 22, 62, 30, Color(0.72, 0.74, 0.78, 1.0))
	_fill(img, 22, 17, 40, 36, Color(0.48, 0.50, 0.54, 1.0))
	_fill(img, 12, 23, 26, 40, Color(0.72, 0.74, 0.78, 1.0))
	_fill(img, 8, 37, 20, 58, Color(0.15, 0.15, 0.18, 1.0))
	_fill(img, 18, 38, 34, 48, Color(0.72, 0.74, 0.78, 1.0))
	return img

func _gen_rifle() -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	_fill(img, 2, 24, 16, 42, Color(0.60, 0.35, 0.22, 1.0))
	_fill(img, 14, 20, 46, 36, Color(0.30, 0.30, 0.33, 1.0))
	_fill(img, 44, 24, 62, 30, Color(0.30, 0.30, 0.33, 1.0))
	_fill(img, 27, 36, 37, 54, Color(0.14, 0.14, 0.16, 1.0))
	return img
