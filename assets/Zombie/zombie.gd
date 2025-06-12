extends CharacterBody3D

@onready var player: CharacterBody3D = %player
@export var SPEED = 5.0
@export var gravity = 10
@export var health = 100
@export var max_health = 100
@export var distance_attack = 10.0  # Distance threshold for chasing player
@export var aggro_duration = 5.0    # How long zombie stays aggressive after being attacked

@onready var animation_zombie: AnimationPlayer = $holder/AnimationPlayer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var damage_timer: Timer = $DamageTimer
@onready var health_bar_container: Control = $SubViewport/HealthBarContainer
@onready var aggro_timer: Timer = $AggroTimer  # Timer for aggro duration

var hide_timer := 0.0
const HIDE_DELAY := 2.0
var player_in_area: bool = false
var is_aggressive: bool = false      # Whether zombie is actively chasing
var is_attacked: bool = false        # Whether zombie was recently attacked

func _ready() -> void:
	print("Player node:", player)
	$holder/AnimationPlayer.play("mixamo_com")
	damage_timer.wait_time = 0.1
	damage_timer.one_shot = false
	health_bar_container.visible = false
	health_bar_container.update_health(health, max_health)
	
	# Setup aggro timer
	add_child(aggro_timer)
	aggro_timer.wait_time = aggro_duration
	aggro_timer.one_shot = true
	aggro_timer.timeout.connect(_on_aggro_timer_timeout)

func _physics_process(delta: float) -> void:
	velocity.y -= gravity
	
	# Check if zombie should be aggressive
	var distance_to_player = global_position.distance_to(player.global_position)
	is_aggressive = (distance_to_player <= distance_attack) or is_attacked
	
	# Only move towards player if aggressive
	if is_aggressive:
		var dir = to_local(navigation_agent_3d.get_next_path_position()).normalized()
		velocity = dir * SPEED
		$holder.look_at(player.position)
	else:
		# Stop moving when not aggressive
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()
	
	if health <= 0:
		die()

func _process(delta):
	if health_bar_container.visible:
		hide_timer -= delta
		if hide_timer <= 0:
			health_bar_container.visible = false

func die():
	set_physics_process(false)
	$CollisionShape3D.disabled = true
	animation_zombie.play("die")
	await get_tree().create_timer(animation_zombie.get_animation("die").length).timeout
	queue_free()

func make_path():
	# Only make path if aggressive
	if is_aggressive:
		navigation_agent_3d.target_position = player.global_position

func damage(x: int):
	health -= x
	health_bar_container.update_health(health, max_health)
	print("Took damage. Health:", health)
	health_bar_container.visible = true
	hide_timer = HIDE_DELAY
	
	# Zombie becomes aggressive when attacked
	is_attacked = true
	aggro_timer.start()  # Reset aggro timer

func _on_timer_timeout() -> void:
	make_path()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		damage_timer.start()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		damage_timer.stop()

func _on_damage_timer_timeout() -> void:
	if player_in_area:
		player.damage(10)

func _on_aggro_timer_timeout() -> void:
	# Stop being aggressive after timer expires (only if player is far away)
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > distance_attack:
		is_attacked = false
