extends CharacterBody3D

@export var SPEED := 7.0
@export var RUN_SPEED := 11.0
@export var JUMP_VELOCITY := 4.5
@export var gravity := 9.8
@export var SENSITIVITY := 0.004

@export var MAX_ENERGY := 15.0
@export var ENERGY_DRAIN := 5.0   # per second when running
@export var ENERGY_RECOVERY := 3.0  # per second when not running
var energy := MAX_ENERGY

@export var max_bullets := 20
var bullet_left := 0  # initialized in _ready()

@export var bullet := preload("res://assets/bullet/bullet.tscn")
@export var max_health :=200
@export var health =200

@onready var head: Node3D = $head
@onready var camera_3d: Camera3D = $head/Camera3D
@onready var gun_raycast: Node3D = $head/Camera3D/gun
@onready var gun_animation: AnimationPlayer = $head/Camera3D/gun/AnimationPlayer

@onready var bullets_label := $head/Camera3D/bullets
@onready var defaite_menu = get_parent().get_node_or_null("DefaiteMenu")
@onready var healthbar := $head/Camera3D/healthbar
@onready var energybar := $head/Camera3D/energybar

func _ready() -> void:
	bullet_left = max_bullets
	health = max_health  # Ensure health is set to max at start
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if defaite_menu:
		defaite_menu.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera_3d.rotate_x(-event.relative.y * SENSITIVITY)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func damage(x:int):
	health -= x
	print("Took damage. Health:", health)
	if health <= 0:
		death()

func _physics_process(delta: float) -> void:
	# UI Updates
	bullets_label.text = str(bullet_left) + " / " + str(max_bullets)
	healthbar.max_value = max_health
	healthbar.value = health
	energybar.max_value = MAX_ENERGY
	energybar.value = energy
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Run / Speed handling
	var is_running = Input.is_action_pressed("speed") and energy > 0 and is_on_floor()
	if is_running:
		SPEED = RUN_SPEED
		energy -= ENERGY_DRAIN * delta
		if energy < 0:
			energy = 0
	else:
		SPEED = 7.0
		energy += ENERGY_RECOVERY * delta
		if energy > MAX_ENERGY:
			energy = MAX_ENERGY

	# Shoot
	if Input.is_action_pressed("shoot") and bullet_left > 0:
		if not gun_animation.is_playing():
			gun_animation.play("shoot")
			shoot()

	# Reload
	if Input.is_action_just_pressed("reload") and is_on_floor():
		if not gun_animation.is_playing():
			gun_animation.play("reload")
			bullet_left = max_bullets

	# Movement
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED - 4.77)
		velocity.z = move_toward(velocity.z, 0, SPEED - 4.77)

	move_and_slide()

func death():
	if defaite_menu:
		defaite_menu.visible = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func shoot():
	bullet_left -= 1
	var bullet_instance = bullet.instantiate()
	bullet_instance.global_transform = gun_raycast.global_transform
	get_parent().add_child(bullet_instance)
