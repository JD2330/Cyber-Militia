extends CharacterBody2D

# ===== HUD =====
var hud: Node = null
var health: float = 100.0

# ===== PLAYER MOVEMENT VARIABLES =====
@export var move_speed: float = 200.0
@export var jump_force: float = -350.0
@export var air_control: float = 0.8
@export var gravity: float = 900.0

# ===== JETPACK VARIABLES =====
@export var jetpack_force: float = -1000.0
@export var max_fuel: float = 100.0
@export var fuel_recharge_rate: float = 20.0
@export var fuel_use_rate: float = 30.0

var fuel: float = max_fuel
var is_using_jetpack: bool = false
var is_jumping : bool = false

# ===== INPUT STATE =====
var input_dir: float = 0.0

# ===== Shoot Variables =====
@export var projectile_scene: PackedScene
@export var muzzle_flash_scene: PackedScene
@export var fire_rate: float = 0.2  # seconds between shots
var can_fire: bool = true

# ===== Grenade Variables =====
@export var grenade_scene: PackedScene
@export var grenade_force: float = 400.0
@export var max_grenades: int = 3
var grenades_left: int = max_grenades

func _ready():
	fuel = max_fuel
	hud = get_tree().root.get_node("Main/HUD")

func _physics_process(delta):
	handle_input()
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	handle_jetpack(delta)
	update_hud()
	move_and_slide()
	print(health)

func handle_input():
	input_dir = Input.get_axis("Left", "Right")
	is_using_jetpack = Input.is_action_pressed("Fly")
	is_jumping = Input.is_action_just_pressed("Jump")
	if Input.is_action_pressed("Shoot") and can_fire:
		fire_weapon()

func handle_jump():
	if is_on_floor() and Input.is_action_just_pressed("Jump"):
		velocity.y = jump_force

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	elif velocity.y > 0:
		velocity.y = 0

func handle_movement(delta):
	# Smooth horizontal control in air
	if is_on_floor():
		velocity.x = input_dir * move_speed
	else:
		velocity.x = lerp(velocity.x, input_dir * move_speed, air_control * delta)

func handle_jetpack(delta):
	if is_using_jetpack and fuel > 0 :
		velocity.y += jetpack_force  * delta 
		fuel -= fuel_use_rate * delta
		fuel = max(fuel, 0)
	elif is_on_floor():
		fuel += fuel_recharge_rate * delta
		fuel = min(fuel, max_fuel)

# ===== OPTIONAL: GET FUEL PERCENT FOR HUD =====
func get_fuel_percent() -> float:
	return fuel / max_fuel
	
func update_hud():
	if hud:
		hud.update_fuel(get_fuel_percent())
		hud.update_health(health)

func fire_weapon():
	can_fire = false
	var projectile = projectile_scene.instantiate()
	projectile.shooter = self
	get_parent().add_child(projectile)
	
	# Get aim direction from mouse position
	var mouse_pos = get_global_mouse_position()
	var shoot_dir = (mouse_pos - global_position).normalized()
	projectile.direction = shoot_dir

	# Spawn slightly ahead of player
	projectile.global_position = global_position + shoot_dir * 20
	
		# Spawn muzzle flash
	if muzzle_flash_scene:
		var flash = muzzle_flash_scene.instantiate()
		flash.global_position = global_position + shoot_dir * 12
		get_parent().add_child(flash)
		
	
	await get_tree().create_timer(fire_rate).timeout
	can_fire = true

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		die()

func die():
	print("Died")
	queue_free() # Temporary; later we’ll handle respawn
	
func _input(event):
	# Secondary fire - right mouse or G key
	if event.is_action_pressed("Secondary-Fire"):
		throw_grenade()
		
func throw_grenade():
	if grenades_left <= 0:
		return
	
	grenades_left -= 1

	var grenade = grenade_scene.instantiate()
	grenade.global_position = global_position
	get_parent().add_child(grenade)

	# Throw in mouse direction
	var dir = (get_global_mouse_position() - global_position).normalized()
	grenade.apply_impulse(dir * grenade_force)
