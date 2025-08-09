extends RigidBody2D

@export var explosion_scene: PackedScene
@export var fuse_time: float = 2

func _ready():
	$Timer.wait_time = fuse_time
	$Timer.start()

func _on_Timer_timeout():
	explode()

func explode():
	if explosion_scene:
		print("Started expload")
		var boom = explosion_scene.instantiate()
		boom.global_position = global_position
		get_parent().add_child(boom)
	queue_free()
