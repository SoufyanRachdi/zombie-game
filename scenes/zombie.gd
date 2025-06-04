extends CharacterBody3D

@onready var player: CharacterBody3D = %player
@export var SPEED = 5.0
@export var gravity = 10
@export var health = 100
@export var max_health = 100
@onready var animation_zombie: AnimationPlayer = $holder/AnimationPlayer

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var damage_timer: Timer = $DamageTimer  # Make sure you add this Timer node in the scene
@onready var health_bar_container: Control = $SubViewport/HealthBarContainer
var hide_timer := 0.0
const HIDE_DELAY := 2.0  # seconds to stay visible

var player_in_area: bool = false  # Tracks if player is in the damage area

func _ready() -> void:
	print("Player node:", player)
	$holder/AnimationPlayer.play("mixamo_com")
	damage_timer.wait_time = 0.1
	damage_timer.one_shot = false
	health_bar_container.visible =false
	# Configure the health bar
	health_bar_container.update_health(health, max_health)
	  # Enable nine-patch stretching
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
	navigation_agent_3d.target_position = player.global_position
	pass

func damage(x:int):
	health -= x
	health_bar_container.update_health(health, max_health)
	print("Took damage. Health:", health)
	health_bar_container.visible = true
	hide_timer = HIDE_DELAY
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
