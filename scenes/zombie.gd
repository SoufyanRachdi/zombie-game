extends CharacterBody3D

@onready var player: CharacterBody3D = %player
@export var SPEED = 5.0
@export var gravity = 10
@export var health = 100
@onready var animation_zombie: AnimationPlayer = $holder/AnimationPlayer

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var damage_timer: Timer = $DamageTimer  # Make sure you add this Timer node in the scene
@onready var healthbar: Node3D = $healthbar
@onready var texture_progress_bar: TextureProgressBar = $healthbar/TextureProgressBar

var player_in_area: bool = false  # Tracks if player is in the damage area

func _ready() -> void:
	print("Player node:", player)
	$holder/AnimationPlayer.play("mixamo_com")
	damage_timer.wait_time = 0.1
	damage_timer.one_shot = false
	
	# Configure the health bar
	texture_progress_bar.max_value = health
	texture_progress_bar.value = health
	texture_progress_bar.size = Vector2(100, 10)  # Set appropriate size
	texture_progress_bar.tint_under = Color(0.2, 0.2, 0.2, 0.8)  # Dark gray background
	texture_progress_bar.tint_progress = Color(0.8, 0.2, 0.2, 0.8)  # Red for health
	texture_progress_bar.tint_over = Color(0, 0, 0, 0)  # Transparent overlay
	texture_progress_bar.nine_patch_stretch = true  # Enable nine-patch stretching
	pass

func _physics_process(delta: float) -> void:
	velocity.y -= gravity
	var dir = to_local(navigation_agent_3d.get_next_path_position()).normalized()
	velocity = dir * SPEED
	move_and_slide()
	$holder.look_at(player.position)
	if(health<=0):
		die()
	pass
func die():
	set_physics_process(false)
	$CollisionShape3D.disabled = true
	animation_zombie.play("die")
	await get_tree().create_timer(animation_zombie.get_animation("die").length).timeout
	queue_free()

func make_path():
	navigation_agent_3d.target_position = player.global_position
	pass

func damage(x:int):
	health -= x
	texture_progress_bar.value = health
	print("Took damage. Health:", health)

func _on_timer_timeout() -> void:
	make_path()
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = true
		damage_timer.start()  # Start damaging every 0.5s
	pass

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_area = false
		damage_timer.stop()  # Stop damaging when player leaves
	pass

func _on_damage_timer_timeout() -> void:
	if player_in_area:
		player.damage(10)  # Ensure `damage()` exists on the player
	pass 
