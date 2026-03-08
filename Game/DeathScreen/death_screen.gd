extends CanvasLayer

func _on_restart_pressed() -> void:
	if has_node("Click"): $Click.play()
	get_tree().change_scene_to_file("res://Game/game.tscn")
func _on_menu_pressed() -> void:
	if has_node("Click"): $Click.play()
	get_tree().change_scene_to_file("res://Menu/Menu.tscn")
