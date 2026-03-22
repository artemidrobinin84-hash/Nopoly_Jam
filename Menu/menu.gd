extends Control


@onready var sound_settings = $Sound_Settings
@onready var credit = $CreditMenu
@onready var play_btn = $Play
@onready var credit_btn = $Credit
@onready var sound_btn = $Sound

func _ready() -> void:
	pivot_offset = size / 2
	
	_safe_connect(credit_btn.pressed, open_credit)
	_safe_connect(sound_btn.pressed, open_settings)
	_safe_connect(play_btn.pressed, _on_play_pressed)
	
	# Кнопки выхода
	_safe_connect($Sound_Settings/TextureRect/Exit1.pressed, close_settings)
	_safe_connect($CreditMenu/TextureRect1/Exit1.pressed, close_credit)

	# Слайдеры звука
	var m_sl = $Sound_Settings/TextureRect/Master
	var mu_sl = $Sound_Settings/TextureRect/Music
	var s_sl = $Sound_Settings/TextureRect/SFX
	
	_safe_connect(m_sl.value_changed, _on_master_value_changed)
	_safe_connect(mu_sl.value_changed, _on_music_value_changed)
	_safe_connect(s_sl.value_changed, _on_sfx_value_changed)

	_safe_connect(play_btn.mouse_entered, _on_button_hover)
	_safe_connect(credit_btn.mouse_entered, _on_button_hover)
	_safe_connect(sound_btn.mouse_entered, _on_button_hover)
func _safe_connect(sig: Signal, target: Callable):
	if !sig.is_connected(target):
		sig.connect(target)

func _on_button_hover() -> void:
	if has_node("Click"): $Click.play()

func open_settings():
	if has_node("Click"): $Click.play()
	if credit.visible:
		credit.visible = false
	
	sound_settings.visible = true
	_animate_open(sound_settings)

func open_credit():
	if has_node("Click"): $Click.play()
	if sound_settings.visible:
		sound_settings.visible = false
	
	credit.visible = true
	_animate_open(credit)


func close_settings():
	if has_node("Click"): $Click.play()
	await _animate_close(sound_settings)
	sound_settings.visible = false

func close_credit():
	if has_node("Click"): $Click.play()
	await _animate_close(credit)
	credit.visible = false


func _on_play_pressed() -> void:
	if has_node("Click"): $Click.play()
	get_tree().change_scene_to_file("res://Game/level/level_1.tscn")


func _on_master_value_changed(v: float): _upd_bus("Master", v)
func _on_music_value_changed(v: float): _upd_bus("Music", v)
func _on_sfx_value_changed(v: float): _upd_bus("SFX", v)

func _upd_bus(bus_name: String, val: float):
	var idx = AudioServer.get_bus_index(bus_name)
	if idx != -1:
		AudioServer.set_bus_volume_db(idx, linear_to_db(val))
		AudioServer.set_bus_mute(idx, val <= 0.001)


func _animate_open(node):
	node.scale = Vector2(1, 0.8)
	node.modulate.a = 0
	var tw = create_tween().set_parallel(true)
	tw.tween_property(node, "modulate:a", 1.0, 0.3)
	tw.tween_property(node, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _animate_close(node):
	var tw = create_tween().set_parallel(true)
	tw.tween_property(node, "modulate:a", 0.0, 0.2)
	tw.tween_property(node, "scale", Vector2(1, 0.8), 0.2)
	return tw.finished
