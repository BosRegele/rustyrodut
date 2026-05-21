extends CanvasLayer

# ── Configurat din player.gd ──────────────────────────────────────────────────
# Apeleaza update_active(slot_int) dupa fiecare schimb de arma.

const SLOT_SIZE      := Vector2(72, 72)
const SLOT_GAP       := 8
const MARGIN_BOTTOM  := 24

# Culorile icon-urilor (inlocuieste cu TextureRect daca adaugi PNG-uri)
const WEAPON_COLORS := [
	Color(0.78, 0.78, 0.82),   # 1 – Pistol  (argintiu)
	Color(0.60, 0.35, 0.22),   # 2 – Rifle   (lemn maro)
]
const WEAPON_NAMES := ["Pistol", "Rifle"]
const KEY_LABELS   := ["[1]", "[2]"]

# Stiluri ──────────────────────────────────────────────────────────────────────
const COL_BG_INACTIVE  := Color(0.09, 0.11, 0.17, 0.92)
const COL_BG_ACTIVE    := Color(0.14, 0.17, 0.27, 0.96)
const COL_BORDER_OUT   := Color(0.12, 0.14, 0.22, 1.00)   # bordura exterioara
const COL_BORDER_IN    := Color(0.88, 0.90, 0.96, 1.00)   # bordura interioara alba
const COL_BORDER_ACT   := Color(1.00, 0.83, 0.18, 1.00)   # gold cand e activ
const COL_KEY_LABEL    := Color(0.75, 0.76, 0.80, 1.00)
const COL_NAME_LABEL   := Color(0.85, 0.86, 0.90, 1.00)

var _slots : Array = []   # Array[Dictionary] – fiecare are "panel", "style_inner"
var _active_slot := 1

func _ready() -> void:
	layer = 20
	_build()
	update_active(1)

# ── Build ──────────────────────────────────────────────────────────────────────
func _build() -> void:
	var slot_count   := WEAPON_NAMES.size()
	var total_width  := slot_count * SLOT_SIZE.x + (slot_count - 1) * SLOT_GAP

	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	hbox.offset_left   = -total_width / 2.0
	hbox.offset_right  =  total_width / 2.0
	hbox.offset_bottom = -MARGIN_BOTTOM
	hbox.offset_top    = -MARGIN_BOTTOM - SLOT_SIZE.y
	hbox.add_theme_constant_override("separation", SLOT_GAP)
	hbox.mouse_filter  = Control.MOUSE_FILTER_IGNORE
	root.add_child(hbox)

	for i in range(slot_count):
		var outer := _make_slot_outer()
		hbox.add_child(outer)

		var inner := _make_slot_inner()
		outer.add_child(inner)

		# ── Icon colorat (Container cu ColorRect) ──
		var icon := ColorRect.new()
		icon.color = WEAPON_COLORS[i]
		icon.set_anchors_preset(Control.PRESET_CENTER)
		icon.size = Vector2(32, 32)
		icon.offset_left   = -16
		icon.offset_right  =  16
		icon.offset_top    = -12
		icon.offset_bottom =  20
		inner.add_child(icon)

		# ── Label tasta [1] / [2] ──
		var key_lbl := Label.new()
		key_lbl.text = KEY_LABELS[i]
		key_lbl.set_anchors_preset(Control.PRESET_TOP_LEFT)
		key_lbl.offset_left = 4
		key_lbl.offset_top  = 2
		key_lbl.add_theme_font_size_override("font_size", 10)
		key_lbl.add_theme_color_override("font_color", COL_KEY_LABEL)
		inner.add_child(key_lbl)

		# ── Label nume arma ──
		var name_lbl := Label.new()
		name_lbl.text = WEAPON_NAMES[i]
		name_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		name_lbl.offset_bottom = -3
		name_lbl.offset_top    = -17
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 10)
		name_lbl.add_theme_color_override("font_color", COL_NAME_LABEL)
		inner.add_child(name_lbl)

		_slots.append({
			"outer": outer,
			"inner": inner,
			"outer_style": outer.get_theme_stylebox("panel") as StyleBoxFlat,
			"inner_style": inner.get_theme_stylebox("panel") as StyleBoxFlat,
		})

# ── Stiluri slot ──────────────────────────────────────────────────────────────
func _make_slot_outer() -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = SLOT_SIZE
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s := StyleBoxFlat.new()
	s.bg_color = COL_BORDER_OUT
	s.set_corner_radius_all(0)
	# Padding intern = grosimea bordurii exterioare (3px)
	s.set_content_margin_all(3.0)
	p.add_theme_stylebox_override("panel", s)
	return p

func _make_slot_inner() -> Panel:
	var p := Panel.new()
	p.set_anchors_preset(Control.PRESET_FULL_RECT)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s := StyleBoxFlat.new()
	s.bg_color = COL_BG_INACTIVE
	s.border_width_left   = 2
	s.border_width_right  = 2
	s.border_width_top    = 2
	s.border_width_bottom = 2
	s.border_color = COL_BORDER_IN
	s.set_corner_radius_all(0)
	s.set_content_margin_all(2.0)
	p.add_theme_stylebox_override("panel", s)
	return p

# ── API public ────────────────────────────────────────────────────────────────
func update_active(slot: int) -> void:
	_active_slot = slot
	for i in range(_slots.size()):
		var d = _slots[i]
		var is_active := (i + 1 == slot)
		(d["inner_style"] as StyleBoxFlat).bg_color     = COL_BG_ACTIVE    if is_active else COL_BG_INACTIVE
		(d["inner_style"] as StyleBoxFlat).border_color = COL_BORDER_ACT   if is_active else COL_BORDER_IN
