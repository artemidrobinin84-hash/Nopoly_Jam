extends TextureProgressBar
@onready var label = $Label 

var flash_tween : Tween

func _ready():
	Rage.rage_bar = self

func flash_red():
	if not label:
		return


	if flash_tween:
		flash_tween.kill()
	
	flash_tween = create_tween()
	
	var normal_color = Color.WHITE
	flash_tween.tween_property(label, "modulate", Color(3, 0, 0), 0.05)
	
	flash_tween.tween_property(label, "modulate", normal_color, 0.15)
	_shake_text()

func _shake_text():
	var original_pos = label.position
	var shake_tween = create_tween()
	shake_tween.tween_property(label, "position", original_pos + Vector2(2, 0), 0.03)
	shake_tween.tween_property(label, "position", original_pos, 0.03)
