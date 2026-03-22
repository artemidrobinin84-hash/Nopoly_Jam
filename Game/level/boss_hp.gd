extends TextureProgressBar 


func _ready():
	
	await get_tree().process_frame
	
	var boss = get_tree().get_first_node_in_group("enemy")
	
	if boss:
		
		boss.hp_changed.connect(_on_boss_hp_changed)
		
		
		_on_boss_hp_changed(boss.current_health, boss.max_health)
	else:
		
		hide()

func _on_boss_hp_changed(current, max_val):
		
	max_value = max_val
	value = current
