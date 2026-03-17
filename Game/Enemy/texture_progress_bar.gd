extends TextureProgressBar

# Теперь родителем является сам Knight, так как мы удалили CanvasLayer
@onready var enemy = get_parent() 

func _ready():
	# Проверяем, есть ли у врага сигнал и подключаем его
	if enemy.has_signal("hp_changed"):
		enemy.hp_changed.connect(_update_hp)
	
	# Сразу обновляем полоску при появлении
	_update_hp(enemy.current_health, enemy.max_health)

func _process(_delta):
	if not is_instance_valid(enemy):
		return
		
	# 1. Считаем реальную ширину полоски с учетом масштаба (Scale)
	var real_width = size.x * scale.x
	
	# 2. Вычисляем позицию: 
	# Берем центр врага, вычитаем половину ширины (чтобы центрировать)
	# и вычитаем высоту (offset_y)
	var final_pos = enemy.global_position
	final_pos.x -= real_width / 2
	final_pos.y -= 50 # Высота над головой
	
	global_position = final_pos
	rotation = 0 # Всегда ровно относительно экрана

func _update_hp(current, max_val):
	max_value = max_val
	value = current
