extends TextureRect

func _ready():
	pivot_offset = size / 2
	start_pulsing()

func start_pulsing():
	var tween = create_tween()
	tween.set_loops() # Бесконечные повторения
	
	# Пульсация: увеличиваем и уменьшаем
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
