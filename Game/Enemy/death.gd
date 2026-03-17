extends GPUParticles2D

func _ready():
	# Сначала сбрасываем состояние, потом запускаем
	emitting = false 
	one_shot = true
	
	# Перезапускаем частицы
	restart() 
	emitting = true
	
	# Если сигнал finished все равно капризничает, 
	# используй более надежный способ через таймер:
	var total_time = lifetime + 0.1 # Время жизни + небольшой запас
	get_tree().create_timer(total_time).timeout.connect(queue_free)
