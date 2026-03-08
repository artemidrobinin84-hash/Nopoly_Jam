extends Node3D
@onready var sun = $DirectionalLight3D
@onready var day_music = $DayMusic
@onready var night_music = $NightMusic
@onready var suspicion_bar = $CanvasLayer/ProgressBar

var is_night = false
var transition_time = 2.0 # Длительность анимации в секундах

func _process(_delta):
 # Плавное заполнение полоски прогресса через lerp
 suspicion_bar.value = lerp(suspicion_bar.value, float(Global.suspicion_value), 0.1)

func _input(event):
 if event.is_action_pressed("Interaction"):
  toggle_night_mode()

func toggle_night_mode():
 is_night = !is_night
 
 # Создаем один твин для всех анимаций
 var tween = create_tween().set_parallel(true)
 
 if is_night:
  # Свет: плавно в 0.1
  tween.tween_property(sun, "light_energy", 0.1, transition_time)
  
  # Музыка: день затихает, ночь нарастает
  fade_music(day_music, night_music, tween)
 else:
  # Свет: плавно в 1.0
  tween.tween_property(sun, "light_energy", 1.0, transition_time)
  
  # Музыка: ночь затихает, день нарастает
  fade_music(night_music, day_music, tween)

func fade_music(from_audio: AudioStreamPlayer3D, to_audio: AudioStreamPlayer3D, tween: Tween):
 # Убедимся, что новая музыка играет, но её не слышно
 if not to_audio.playing:
  to_audio.play()
  to_audio.volume_db = -80
 
 # Уводим громкость старой в -80 и новой в 0
 tween.tween_property(from_audio, "volume_db", -80, transition_time)
 tween.tween_property(to_audio, "volume_db", 15, transition_time)
 
 # После завершения анимации можно остановить старый поток (опционально)
 # tween.chain().step_property(from_audio, "playing", false)
