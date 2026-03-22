extends Node

@onready var fx_layer = CanvasLayer.new()
@onready var flash_rect = ColorRect.new()
@onready var chrom_rect = ColorRect.new()

var chromatic_shader = preload("res://chromatic_aberration.gdshader")

func _ready():

	process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(fx_layer)
	fx_layer.layer = 128
	

	chrom_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var mat = ShaderMaterial.new()
	mat.shader = chromatic_shader
	chrom_rect.material = mat
	chrom_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chrom_rect.visible = false
	fx_layer.add_child(chrom_rect)

	flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_rect.color = Color(1, 1, 1, 0)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx_layer.add_child(flash_rect)

func hit_stop(duration: float):
	Engine.time_scale = 0.0

	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0

func hit_flash(duration: float, max_alpha: float = 0.3):
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	flash_rect.color.a = max_alpha
	tween.tween_property(flash_rect, "color:a", 0.0, duration)

func do_chromatic(duration: float, strength: float):
	chrom_rect.visible = true
	var mat = chrom_rect.material
	mat.set_shader_parameter("amount", strength)
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(mat, "shader_parameter/amount", 0.0, duration)
	
	await tween.finished
	if mat.get_shader_parameter("amount") <= 0.1:
		chrom_rect.visible = false

func play_ultra_sound(stream: AudioStream):
	if stream == null: return

	var new_player = AudioStreamPlayer.new()
	new_player.stream = stream
	new_player.volume_db = -5.0
	new_player.process_mode = Node.PROCESS_MODE_ALWAYS 
	
	add_child(new_player)
	new_player.play()

	new_player.finished.connect(new_player.queue_free)
