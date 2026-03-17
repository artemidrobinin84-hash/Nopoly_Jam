extends CharacterBody2D

# --- Настройки деша ---
@export var dash_speed := 3000.0     # Скорость рывка (сделай побольше для резкости)
@export var dash_duration := 0.25  # Длительность самого рывка
@export var dash_cooldown := 0.01   # Перезарядка
var can_dash = true
var is_dashing = false

# Твои старые переменные
var shake_strength : float = 0.0
@export var shake_fade : float = 15.0
@export var max_health : int = 100
@export var speed := 150.0
@export var attack_damage : int = 10
@export var explosion_scene : PackedScene 

@onready var camera = $Camera2D
@onready var snap_sound = $Snap

var current_health : int
var is_attacking = false

func _ready():
	current_health = max_health
	add_to_group("player")

func _physics_process(_delta):
	# Если мы в рывке — просто движемся и не даем игроку менять направление
	if is_dashing:
		move_and_slide()
		return

	# Обычное движение
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	# Поворот за мышкой
	$Sprite2D.look_at(get_global_mouse_position())
	
	move_and_slide()

# Процесс для плавной тряски (как мы делали раньше)
func _process(delta):
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		if camera:
			camera.offset = Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))
	elif camera and camera.offset != Vector2.ZERO:
		camera.offset = Vector2.ZERO

func _input(event):
	# Атака на левую кнопку (или твой экшен attack)
	if event.is_action_pressed("attack") and not is_attacking:
		start_attack()
	
	# Рывок на ПРАВУЮ КНОПКУ МЫШИ (или Shift)
	# Замени "right_click" на свое название в Input Map, если нужно
	if event.is_action_pressed("ui_select") or event.is_action_pressed("dash"): 
		if can_dash and not is_dashing:
			perform_dash()

func perform_dash():
	can_dash = false
	is_dashing = true
	$Sprite2D/Sprite2D.show()
	snap_sound.play()
	# 1. Взрыв на месте СТАРТА
	if explosion_scene:
		var e = explosion_scene.instantiate()
		e.damage = attack_damage
		get_tree().current_scene.add_child(e)
		e.global_position = global_position
	
	# 2. Направление к мышке
	var mouse_pos = get_global_mouse_position()
	var dash_dir = (mouse_pos - global_position).normalized()
	
	# Устанавливаем скорость деша
	velocity = dash_dir * dash_speed
	
	# Эффекты
	shake_camera(10.0)
	
	# 3. Таймер самого рывка
	await get_tree().create_timer(dash_duration).timeout
	$Sprite2D/Sprite2D.hide()
	is_dashing = false
	# После деша резко сбавляем скорость, чтобы не скользить
	velocity = Vector2.ZERO 
	
	# 4. Таймер перезарядки
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
func start_attack():
	if explosion_scene == null: 
		print("ОШИБКА: Забыли перетащить сцену взрыва!")
		return
		
	is_attacking = true
	
	var e = explosion_scene.instantiate()
	e.damage = attack_damage 
	get_tree().current_scene.add_child(e)
	e.global_position = get_global_mouse_position()
	
	# Вызываем тряску (теперь она суммируется)
	shake_camera(7.0) # Для атаки можно поменьше
	snap_sound.play()
	
	await get_tree().create_timer(0.2).timeout
	is_attacking = false

# ТЕПЕРЬ ТУТ НЕТ TWEEN - только добавление силы
func shake_camera(amount: float):
	shake_strength += amount

func take_damage(amount: int):
	current_health -= amount
	var t = create_tween()
	t.tween_property(self, "modulate", Color.RED, 0.05)
	t.tween_property(self, "modulate", Color.WHITE, 0.05)
	if current_health <= 0:
		call_deferred("_change_scene")

func _change_scene():
	get_tree().change_scene_to_file("res://Menu/Menu.tscn")
