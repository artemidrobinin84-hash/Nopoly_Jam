extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):

		call_deferred("_change_scene")

func _change_scene():
	get_tree().change_scene_to_file("res://Game/level/level_2.tscn")
