extends RigidBody3D

const SPEED := 60.0

var _lifetime := 4.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body.has_method("hit"):
		body.hit()
	queue_free()
