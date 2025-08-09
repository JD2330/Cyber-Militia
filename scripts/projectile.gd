extends Area2D

@export var speed: float = 500.0
@export var damage: float = 20.0
var direction: Vector2 = Vector2.RIGHT
var shooter = null

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta
	else:
		queue_free() # No direction? Destroy instantly.

func _on_body_entered(body):
	if body == shooter:
		return  # Ignore the player who fired it
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
