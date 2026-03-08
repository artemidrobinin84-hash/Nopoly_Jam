extends CharacterBody3D
@onready var suspicion_music = $"../Sus" # Убедись, что путь верный
var is_suspicion_music_playing = false
# --- Настройки движения ---
@export var speed := 2.0
@export var wander_time := 2.0
@export var idle_time := 1.5

# --- Переменные подозрения ---
var character_in_area := false
var base_rate := 5.0
var decay_rate := 3.0
var current_rate := 0.0
var smoothness := 2.0

# --- Внутренние переменные ---
var move_direction := Vector3.ZERO
var timer := 0.0
var is_moving := false

# Получаем гравитацию из настроек проекта
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
 pick_new_state()

func _physics_process(delta):
 # 0. ГРАВИТАЦИЯ (чтобы NPC не летал)
 if not is_on_floor():
  velocity.y -= gravity * delta

 # 1. ТАЙМЕР И СОСТОЯНИЯ
 timer -= delta
 if timer <= 0:
  pick_new_state()

 # 2. ДВИЖЕНИЕ
 if is_moving:
  velocity.x = move_direction.x * speed
  velocity.z = move_direction.z * speed

 else:
  velocity.x = move_toward(velocity.x, 0, speed * delta)
  velocity.z = move_toward(velocity.z, 0, speed * delta)

 move_and_slide()

 # 3. ЛОГИКА ПОДОЗРЕНИЯ
 var target_rate = base_rate if character_in_area else -decay_rate
 current_rate = lerp(current_rate, target_rate, smoothness * delta)
 
 Global.suspicion_value = clamp(Global.suspicion_value + current_rate * delta, 0.0, 100.0)
 
 # ПРОВЕРКА ПРОИГРЫША
 if Global.suspicion_value >= 100.0:
  Global.suspicion_value = 0.0
  get_tree().change_scene_to_file("res://Game/DeathScreen/DeathScreen.tscn")

func pick_new_state():
 is_moving = randf() > 0.3
 if is_moving:
  var direction = 1 if randf() > 0.5 else -1
  move_direction = Vector3(direction, 0, 0)
  timer = randf_range(1.0, wander_time)
 else:
  timer = randf_range(0.5, idle_time)

# --- Сигналы (убедись, что они подключены в инспекторе!) ---
func _on_detection_area_body_entered(body):
 if body.is_in_group("Player"):
  character_in_area = true

func _on_detection_area_body_exited(body):
 if body.is_in_group("Player"):
  character_in_area = false

func check_suspicion_music():
 # Если подозрение выше 50 и музыка еще не включена
 if Global.suspicion_value >= 50.0 and not is_suspicion_music_playing:
  if not suspicion_music.playing:
   suspicion_music.play()
  is_suspicion_music_playing = true
  print("Тревожная музыка включена!")
 
 # Если подозрение упало ниже 45 (небольшой запас, чтобы музыка не дергалась туда-сюда)
 elif Global.suspicion_value < 45.0 and is_suspicion_music_playing:
  suspicion_music.stop()
  is_suspicion_music_playing = false
  print("Стало спокойнее, выключаем.")
