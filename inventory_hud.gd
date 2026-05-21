extends CanvasLayer

const SLOT_SIZE     := Vector2(80, 80)
const SLOT_GAP      := 10
const MARGIN_BOTTOM := 24

const WEAPON_ICONS := [
	"res://icon_pistol.png",
	"res://icon_rifle.png",
]
const WEAPON_NAMES := ["Pistol", "Rifle"]
const KEY_LABELS   := ["[1]", "[2]"]

const COL_BG_INACTIVE := Color(0.09, 0.11, 0.17, 0.92)
const COL_BG_ACTIVE   := Color(0.14, 0.17, 0.27, 0.96)
const COL_BORDER_OUT  := Color(0.12, 0.14, 0.22, 1.00)
const COL_BORDER_IN   := Color(0.88, 0.90, 0.96, 1.00)
const COL_BORDER_ACT  := Color(1.00, 0.83, 0.18, 1.00)
const COL_KEY_LABEL   := Color(0.75, 0.76, 0.80, 1.00)
const COL_NAME_LABEL  := Color(0.85, 0.86, 0.90, 1.00)

var _slots       : Array = []
var _active_slot := 1

func _ready() -> void:
	layer = 20
	_ensure_icons()
	_build()
	update_active(1)

# ── Genereaza PNG-urile daca nu exista ─────────────────────────────────────────
func _ensure_icons() -> void:
	var pistol_path := ProjectSettings.globalize_path("res://icon_pistol.png")
	var rifle_path  := ProjectSettings.globalize_path("res://icon_rifle.png")
	if not FileAccess.file_exists(pistol_path):
		_gen_pistol().save_png(pistol_path)
	if not FileAccess.file_exists(rifle_path):
		_gen_rifle().save_png(rifle_path)

# ── Pixel helper ───────────────────────────────────────────────────────────────
func _fill(img: Image, x1: int, y1: int, x2: int, y2: int, c: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for py in range(max(0, y1), min(h, y2)):
		for px in range(max(0, x1), min(w, x2)):
			img.set_pixel(px, py, c)

# ── Taurus Raging Judge (argintiu, barrel lung, pointing right) ────────────────
func _gen_pistol() -> Image:
	var img  := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var silver := Color(0.72, 0.74, 0.78, 1.0)
	var metal  := Color(0.48, 0.50, 0.54, 1.0)
	var dark   := Color(0.15, 0.15, 0.18, 1.0)
	var red    := Color(0.85, 0.12, 0.12, 1.0)

	# Barrel lung (caracteristic Raging Judge)
	_fill(img, 36, 22, 62, 30, silver)
	# Nervura de sus a barrel-ului
	_fill(img, 38, 20, 60, 22, metal)
	# Front sight (rosu)
	_fill(img, 59, 19, 63, 23, red)

	# Cylinder mare
	_fill(img, 22, 17, 40, 36, metal)
	# Flute-uri cylinder
	_fill(img, 24, 19, 26, 34, dark)
	_fill(img, 28, 19, 30, 34, dark)
	_fill(img, 33, 19, 35, 34, dark)
	_fill(img, 37, 19, 39, 34, dark)

	# Frame principal
	_fill(img, 12, 23, 26, 40, silver)

	# Hammer
	_fill(img, 13, 15, 22, 24, dark)
	_fill(img, 19, 13, 24, 19, dark)

	# Trigger guard
	_fill(img, 18, 38, 34, 40, silver)
	_fill(img, 18, 38, 20, 48, silver)
	_fill(img, 32, 38, 34, 48, silver)
	_fill(img, 18, 46, 34, 48, silver)
	# Trigger
	_fill(img, 24, 38, 28, 46, dark)

	# Grip (maner negru/cauciuc)
	_fill(img, 8, 37, 20, 58, dark)
	# Suruburi grip
	_fill(img, 10, 41, 13, 44, silver)
	_fill(img, 15, 51, 18, 54, silver)
	# Highlight grip
	_fill(img, 9, 38, 11, 56, Color(0.25, 0.25, 0.28, 1.0))

	return img

# ── Federov Avtomat (lemn brun + metal, pointing right) ───────────────────────
func _gen_rifle() -> Image:
	var img  := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var wood      := Color(0.60, 0.35, 0.22, 1.0)
	var wood_dark := Color(0.45, 0.25, 0.14, 1.0)
	var metal     := Color(0.30, 0.30, 0.33, 1.0)
	var dark      := Color(0.14, 0.14, 0.16, 1.0)
	var metal_l   := Color(0.42, 0.42, 0.46, 1.0)

	# Pat (stock) lemn
	_fill(img, 2, 24, 16, 42, wood)
	_fill(img, 2, 24,  4, 42, wood_dark)
	_fill(img, 2, 40, 16, 42, wood_dark)

	# Pistol grip lemn
	_fill(img, 14, 33, 22, 48, wood)
	_fill(img, 14, 33, 16, 48, wood_dark)

	# Receiver / carc
	_fill(img, 14, 20, 46, 36, metal)
	_fill(img, 14, 20, 46, 22, dark)   # top edge

	# Sina de sus (top rail)
	_fill(img, 16, 17, 44, 21, dark)

	# Barrel (teava lunga)
	_fill(img, 44, 24, 62, 30, metal)
	# Gas tube (deasupra teavii)
	_fill(img, 44, 22, 60, 25, dark)

	# Incarcator (magazine) negru cu nervuri
	_fill(img, 27, 36, 37, 54, dark)
	_fill(img, 29, 37, 31, 53, metal_l)
	_fill(img, 33, 37, 35, 53, metal_l)

	# Trigger guard
	_fill(img, 23, 34, 38, 36, metal)
	_fill(img, 23, 34, 25, 42, metal)
	_fill(img, 36, 34, 38, 42, metal)
	_fill(img, 23, 40, 38, 42, metal)

	# Mecanism fata + protectie teava
	_fill(img, 44, 21, 60, 25, metal_l)

	# Muzzle brake (frână gura de foc)
	_fill(img, 60, 22, 64, 31, dark)
	_fill(img, 60, 24, 63, 26, metal_l)
	_fill(img, 60, 27, 63, 29, metal_l)

	# Front sight
	_fill(img, 56, 20, 60, 23, metal)

	return img

# ── Build HUD ─────────────────────────────────────────────────────────────────
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
		var outer := _make_outer()
		hbox.add_child(outer)

		# Icon arma
		var icon_path: String = WEAPON_ICONS[i]
		if ResourceLoader.exists(icon_path):
			var tex_rect := TextureRect.new()
			tex_rect.texture = load(icon_path)
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
			tex_rect.offset_left   =  4
			tex_rect.offset_right  = -4
			tex_rect.offset_top    =  4
			tex_rect.offset_bottom = -18
			tex_rect.mouse_filter  = Control.MOUSE_FILTER_IGNORE
			outer.add_child(tex_rect)

		# Label tasta
		var key_lbl := Label.new()
		key_lbl.text = KEY_LABELS[i]
		key_lbl.set_anchors_preset(Control.PRESET_TOP_LEFT)
		key_lbl.offset_left = 5
		key_lbl.offset_top  = 3
		key_lbl.add_theme_font_size_override("font_size", 11)
		key_lbl.add_theme_color_override("font_color", COL_KEY_LABEL)
		key_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		outer.add_child(key_lbl)

		# Label nume
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
	s.border_color  = COL_BORDER_IN
	s.shadow_color  = COL_BORDER_OUT
	s.shadow_size   = 3
	s.set_corner_radius_all(0)
	p.add_theme_stylebox_override("panel", s)
	return p

# ── API ────────────────────────────────────────────────────────────────────────
func update_active(slot: int) -> void:
	_active_slot = slot
	for i in range(_slots.size()):
		var s := _slots[i]["outer_style"] as StyleBoxFlat
		var active := (i + 1 == slot)
		s.bg_color     = COL_BG_ACTIVE  if active else COL_BG_INACTIVE
		s.border_color = COL_BORDER_ACT if active else COL_BORDER_IN
