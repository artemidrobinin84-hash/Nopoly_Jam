extends CharacterBody2D

@export var dash_speed := 3000.0     
@export var dash_duration := 0.25  
@export var dash_cooldown := 0.01   
var can_dash = true
var is_dashing = false
@export var is_in_cutscene := false
@export var max_health : int = 100
@export var speed := 150.0
@export var attack_damage : int = 10
@export var explosion_scene : PackedScene 
@export var rage_power_mult := 50.0
@export var max_rage : float = 100.0
@export var rage_gain_rate := 0.01
var current_rage : float = 0.0
var shake_strength : float = 0.0
@export var shake_fade : float = 15.0
@onready var camera = $Camera2D
@onready var snap_sound = $Snap
var current_health : int
var is_attacking = false

func _ready():
	current_health = max_health
	add_to_group("player")
	current_rage = 0.0
	update_rage_ui()

func _physics_process(_delta):
	if is_in_cutscene:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if is_dashing:
		move_and_slide()
		return
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	if has_node("Sprite2D"):
		$Sprite2D.look_at(get_global_mouse_position())
	
	move_and_slide()

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		if camera:
			camera.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
	elif camera and camera.offset != Vector2.ZERO:
		camera.offset = Vector2.ZERO
func _input(event):
	if is_in_cutscene:
		return 
	if event.is_action_pressed("attack") and not is_attacking:
		start_attack()
	
	if event.is_action_pressed("ui_select") or event.is_action_pressed("dash"): 
		if can_dash and not is_dashing:
			perform_dash()


func perform_dash():
	if is_in_cutscene: return
	can_dash = false
	is_dashing = true
	
	var multiplier = 1.0 + (current_rage / max_rage) * rage_power_mult
	
	if has_node("Sprite2D/Sprite2D"): $Sprite2D/Sprite2D.show()
	if snap_sound: snap_sound.play()
	
	spawn_explosion(global_position, multiplier)
	
	var mouse_pos = get_global_mouse_position()
	var dash_dir = (mouse_pos - global_position).normalized()
	velocity = dash_dir * dash_speed
	shake_camera(10.0 * multiplier)
	current_rage = 0
	update_rage_ui()
	
	await get_tree().create_timer(dash_duration).timeout
	if has_node("Sprite2D/Sprite2D"): $Sprite2D/Sprite2D.hide()
	is_dashing = false
	velocity = Vector2.ZERO 
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func start_attack():
	if is_in_cutscene: 
		print("Клик был, но я в катсцене, взрыв отменяется!")
		return
		
	if explosion_scene == null: return
		
	is_attacking = true
	var multiplier = 1.0 + (current_rage / max_rage) * rage_power_mult
	spawn_explosion(get_global_mouse_position(), multiplier)
	
	shake_camera(7.0 * multiplier)
	if snap_sound: snap_sound.play()
	current_rage = 0
	update_rage_ui()
	await get_tree().create_timer(0.2).timeout
	is_attacking = false

func spawn_explosion(pos: Vector2, mult: float):
	if explosion_scene:
		var e = explosion_scene.instantiate()
		if "damage" in e: e.damage = attack_damage * mult
		e.scale = Vector2.ONE * mult
		get_tree().current_scene.add_child(e)
		e.global_position = pos

func shake_camera(amount: float):
	shake_strength += amount

func take_damage(amount: int):
	current_health -= amount
	
	current_rage = clamp(current_rage + (amount * rage_gain_rate * 10.0), 0, max_rage)
	update_rage_ui()
	
	if Rage.rage_bar != null and Rage.rage_bar.has_method("flash_red"):
		Rage.rage_bar.flash_red()
	
	if current_health <= 0:
		call_deferred("_change_scene")

func update_rage_ui():
	if Rage.rage_bar != null:
		Rage.rage_bar.value = current_rage
	else:
		var found_bar = get_tree().get_first_node_in_group("rage_ui")
		if found_bar:
			Rage.rage_bar = found_bar
			Rage.rage_bar.value = current_rage

func _change_scene():
	get_tree().quit() 
