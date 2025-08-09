extends Area2D

@export var damage: int = 50

func _ready() -> void:
	print("started do_damage")
	for body in get_overlapping_bodies():
		print("overlaping a body")
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Damaged")
	#$Particles2D.emitting = true
	$Sprite2D.visible = true
	await get_tree().create_timer(0.3).timeout
	$Sprite2D.queue_free()
	queue_free()
	print("Explod")
	# Deal damage to everyone inside immediately
func do_damage():
	pass
