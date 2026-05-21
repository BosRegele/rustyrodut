extends StaticBody3D

var health := 3
var _mat: StandardMaterial3D

@onready var mesh_inst: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	_mat = StandardMaterial3D.new()
	_mat.albedo_color = Color(0.85, 0.18, 0.18)
	mesh_inst.set_surface_override_material(0, _mat)

func hit() -> void:
	health -= 1
	match health:
		2: _mat.albedo_color = Color(0.9, 0.5, 0.1)
		1: _mat.albedo_color = Color(0.9, 0.82, 0.1)
		0: queue_free()
