extends Area2D

@onready var anim_player = $"../AnimationPlayer"
@onready var boss = $"../CharacterBody2D" 
@onready var cutscene_camera = $"../CutsceneCamera"
var triggered = false 

func _on_body_entered(body):
	# Проверяем по имени или по группе, что это игрок
	if body.name == "Exploid" and not triggered:
		triggered = true
		run_full_cutscene(body)

func run_full_cutscene(player_node):
	if Rage.rage_bar == null:
		Rage.rage_bar = get_tree().get_first_node_in_group("rage_ui")
	
	if Rage.rage_bar:
		Rage.rage_bar.hide()
	player_node.set_physics_process(false)
	if cutscene_camera:
		cutscene_camera.make_current()
	
	anim_player.play("boss_intro")
	
	await anim_player.animation_finished

	if Rage.rage_bar:
		Rage.rage_bar.show()
		print("Катсцена: Полоску показали")

	if boss:
		boss.is_active = true
	
	var player_cam = player_node.get_node_or_null("Camera2D")
	if player_cam:
		player_cam.make_current()
	
	player_node.set_physics_process(true)
