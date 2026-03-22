extends Node2D

@onready var normal_music = $NormalMusic
@onready var boss_music = $BossMusic
@onready var rage_music = $RageMusic

var current_main_track : AudioStreamPlayer 
var is_rage_active = false
var player = null

func _ready():
	current_main_track = normal_music
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	var boss = get_tree().get_first_node_in_group("enemy")
	
	if boss and boss.has_signal("boss_appeared"):
		boss.boss_appeared.connect(_on_boss_started)

func _process(_delta):
	if player:
		if player.current_rage >= player.max_rage and not is_rage_active:
			_switch_to_rage(true)
		elif player.current_rage < player.max_rage and is_rage_active:
			_switch_to_rage(false)

func _on_boss_started():
	if current_main_track == boss_music: return
	
	var tween = create_tween()
	tween.parallel().tween_property(current_main_track, "volume_db", -80.0, 1.5)
	
	current_main_track = boss_music
	current_main_track.play()
	
	if not is_rage_active:
		tween.parallel().tween_property(current_main_track, "volume_db", 0.0, 1.5)

func _switch_to_rage(activate: bool):
	is_rage_active = activate
	var tween = create_tween()
	
	if activate:
		tween.parallel().tween_property(current_main_track, "volume_db", -80.0, 0.4)
		tween.parallel().tween_property(rage_music, "volume_db", 0.0, 0.4)
	else:
		tween.parallel().tween_property(current_main_track, "volume_db", 0.0, 0.6)
		tween.parallel().tween_property(rage_music, "volume_db", -80.0, 0.6)
