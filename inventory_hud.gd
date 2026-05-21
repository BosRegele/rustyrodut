extends CanvasLayer

const SLOT_SIZE     := Vector2(80, 80)
const SLOT_GAP      := 10
const MARGIN_BOTTOM := 24

const SLOT_FRAME  := "res://icon_slot.png"
const WEAPON_ICONS := [
	"res://icon_pistol.png",   # slot 1
	"res://icon_rifle.png",    # slot 2
]
const WEAPON_NAMES  := ["Pistol", "Rifle"]
const KEY_LABELS    := ["[1]", "[2]"]

# Fallback colors daca PNG-urile lipsesc
const WEAPON_COLORS := [
	Color(0.78, 0.78, 0.82),
	Color(0.60, 0.35, 0.22),
]

const COL_BG_INACTIVE := Color(0.09, 0.11, 0.17, 0.92)
const COL_BG_ACTIVE   := Color(0.14, 0.17, 0.27, 0.96)
const COL_BORDER_OUT  := Color(0.12, 0.14, 0.22, 1.00)
const COL_BORDER_IN   := Color(0.88, 0.90, 0.96, 1.00)
const COL_BORDER_ACT  := Color(1.00, 0.83, 0.18, 1.00)
const COL_KEY_LABEL   := Color(0.75, 0.76, 0.80, 1.00)
const COL_NAME_LABEL  := Color(0.85, 0.86, 0.90, 1.00)

var _slots       : Array = []
var _active_slot := 1
var _use_frame   := false

func _ready() -> void:
	layer = 20
	_use_frame = ResourceLoader.exists(SLOT_FRAME)
	_build()
	update_active(1)

# ── Build ──────────────────────────────────────────────────────────────────────
func _build() -> void:
	var count       := WEAPON_NAMES.size()
	var total_width := count * SLOT_SIZE.x + (count - 1) * SLOT_GAP

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

	for i in range(count):
		# ── Container exterior (border / frame) ──────────────────────────────
		var outer := _make_outer()
		hbox.add_child(outer)

		# ── Icon arma ────────────────────────────────────────────────────────
		var icon_path: String = WEAPON_ICONS[i]
		if ResourceLoader.exists(icon_path):
			var tex_rect := TextureRect.new()
			tex_rect.texture = load(icon_path)
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			# margine interioara sa nu atinga bordura
			tex_rect.offset_left   = 6
			tex_rect.offset_right  = -6
			tex_rect.offset_top    = 6
			tex_rect.offset_bottom = -20   # loc pentru label jos
			tex_rect.mouse_filter  = Control.MOUSE_FILTER_IGNORE
			outer.add_child(tex_rect)
		else:
			# Fallback: patrat colorat
			var col_rect := ColorRect.new()
			col_rect.color = WEAPON_COLORS[i]
			col_rect.set_anchors_preset(Control.PRESET_CENTER)
			col_rect.size         = Vector2(36, 36)
			col_rect.offset_left  = -18
			col_rect.offset_right =  18
			col_rect.offset_top   = -14
			col_rect.offset_bottom = 22
			col_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			outer.add_child(col_rect)

		# ── Overlay rama PNG (transparent center) ────────────────────────────
		if _use_frame:
			var frame_rect := TextureRect.new()
			frame_rect.texture = load(SLOT_FRAME)
			frame_rect.stretch_mode = TextureRect.STRETCH_SCALE
			frame_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			frame_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			outer.add_child(frame_rect)

		# ── Label tasta ──────────────────────────────────────────────────────
		var key_lbl := Label.new()
		key_lbl.text = KEY_LABELS[i]
		key_lbl.set_anchors_preset(Control.PRESET_TOP_LEFT)
		key_lbl.offset_left = 5
		key_lbl.offset_top  = 3
		key_lbl.add_theme_font_size_override("font_size", 11)
		key_lbl.add_theme_color_override("font_color", COL_KEY_LABEL)
		key_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		outer.add_child(key_lbl)

		# ── Label nume arma ──────────────────────────────────────────────────
		var name_lbl := Label.new()
		name_lbl.text = WEAPON_NAMES[i]
		name_lbl.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		name_lbl.offset_bottom = -3
		name_lbl.offset_top    = -18
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.add_theme_color_override("font_color", COL_NAME_LABEL)
		name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		outer.add_child(name_lbl)

		_slots.append({
			"outer":       outer,
			"outer_style": outer.get_theme_stylebox("panel") as StyleBoxFlat,
		})

# ── Outer panel cu StyleBoxFlat (folosit si cand lipseste frame PNG) ───────────
func _make_outer() -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = SLOT_SIZE
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s := StyleBoxFlat.new()
	s.bg_color = COL_BG_INACTIVE
	s.border_width_left   = 3
	s.border_width_right  = 3
	s.border_width_top    = 3
	s.border_width_bottom = 3
	s.border_color = COL_BORDER_IN
	# bordura exterioara dark (simulam shadow-ul din pixel art)
	s.shadow_color = COL_BORDER_OUT
	s.shadow_size  = 3
	s.set_corner_radius_all(0)
	p.add_theme_stylebox_override("panel", s)
	return p

# ── API ────────────────────────────────────────────────────────────────────────
func update_active(slot: int) -> void:
	_active_slot = slot
	for i in range(_slots.size()):
		var s := _slots[i]["outer_style"] as StyleBoxFlat
		var active := (i + 1 == slot)
		s.bg_color     = COL_BG_ACTIVE   if active else COL_BG_INACTIVE
		s.border_color = COL_BORDER_ACT  if active else COL_BORDER_IN
