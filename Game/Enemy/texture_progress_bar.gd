extends TextureProgressBar

@onready var enemy = get_parent() 

func _ready():

	if enemy.has_signal("hp_changed"):
		enemy.hp_changed.connect(_update_hp)
	
	_update_hp(enemy.current_health, enemy.max_health)

func _process(_delta):
	if not is_instance_valid(enemy):
		return
		
	var real_width = size.x * scale.x
	
	var final_pos = enemy.global_position
	final_pos.x -= real_width / 2
	final_pos.y -= 50
	
	global_position = final_pos
	rotation = 0

func _update_hp(current, max_val):
	max_value = max_val
	value = current
