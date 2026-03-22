extends CharacterBody2D

signal hp_changed(current, max_val)
@export var max_health : int = 50
var current_health : int
@export var attack_offset := 20.0
@onready var sprite = $Knight
@onready var attack_visual = $Area2D/Attac
const BLOOD_SCENE = preload("res://Game/Enemy/Death.tscn")
@export var speed : float = 80.0
@export var attack_damage : int = 15
@export var stop_distance : float = 0
var can_attack = true 
var player = null
var is_attacking = false
var knockback_velocity = Vector2.ZERO
@export var attack_cooldown : float = 1.5
@export var attack_range : float = 30.0
@onready var slash = $Slash
@onready var ultra = $ultra

func _ready():
	current_health = 50
	add_to_group("enemy")
	current_health = max_health
	hp_changed.emit(current_health, max_health)
func _physics_process(delta):
	if player == null or not is_instance_valid(player):
		find_player()
		return
	
	look_at(player.global_position)
	var dist = global_position.distance_to(player.global_position)
	var dir = (player.global_position - global_position).normalized()
	var move_vel = Vector2.ZERO
	
	if dist > stop_distance and not is_attacking:
		move_vel = dir * speed
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1500 * delta)
	velocity = move_vel + knockback_velocity
	move_and_slide()
	
	if dist <= stop_distance + 100 and not is_attacking and can_attack:
		start_attack()

func find_player():
	if not is_inside_tree():
		return
	var p = get_tree().get_nodes_in_group("player")
	if p.size() > 0: 
		player = p[0]

func apply_knockback(source_pos: Vector2, strength: float):
	var push_dir = (global_position - source_pos).normalized()
	knockback_velocity = push_dir * strength


func take_damage(amount: int):
	current_health -= amount
	hp_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		if current_health <= 0:
			if Engine.time_scale > 0:
				GlobalEffects.hit_stop(0.1)
				GlobalEffects.hit_flash(0.1, 0.2)
				GlobalEffects.do_chromatic(0.3, 8.0)
				GlobalEffects.play_ultra_sound(ultra.stream)
		if is_instance_valid(player) and player.has_method("shake_camera"):
			player.shake_camera(20.0)
		
		spawn_blood()
		visible = false
		set_physics_process(false) 
		queue_free()
func spawn_blood():
	if not BLOOD_SCENE or not is_inside_tree():
		return
		
	var blood = BLOOD_SCENE.instantiate()
	get_parent().add_child(blood)
	blood.global_position = global_position
	
	if player:
		var direction = (global_position - player.global_position).angle()
		blood.rotation = direction

func start_attack():
	is_attacking = true
	can_attack = false
	await melee_attack()
	is_attacking = false
	
	if is_inside_tree():
		await get_tree().create_timer(attack_cooldown).timeout
		can_attack = true

func melee_attack():
	if not is_inside_tree(): return
	
	var attack_direction = player.global_position
	
	if attack_visual:
		attack_visual.global_position = attack_direction
		slash.play()
		attack_visual.visible = true
		attack_visual.play("Attack")
	
	await get_tree().create_timer(0.1).timeout
	
	if not is_inside_tree(): return 
	
	if player and is_instance_valid(player) and global_position.distance_to(player.global_position) < attack_range * 1.5:
		if player.has_method("take_damage"):
			player.take_damage(attack_damage)
	
	await get_tree().create_timer(0.1).timeout
	
	if not is_inside_tree(): return
	
	if attack_visual:
		attack_visual.visible = false
		attack_visual.stop()
	await get_tree().create_timer(0.15).timeout
	if not is_inside_tree(): return
	
	
	if player and is_instance_valid(player) and is_inside_tree():
		if global_position.distance_to(player.global_position) < attack_range * 1.5:
			if player.has_method("take_damage"):
				player.take_damage(attack_damage)
	
	if is_inside_tree():
		await get_tree().create_timer(0.1).timeout
	else:
		return
	
	if attack_visual and is_inside_tree():
		attack_visual.visible = false
		attack_visual.stop()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(attack_damage)
