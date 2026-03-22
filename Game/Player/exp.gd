extends Area2D

@onready var exp_anim = $AnimatedSprite2D2
@onready var rune = $Rune
@onready var particles = $AnimatedSprite2D2/GPUParticles2D
@onready var sounds = [$Boom, $Boom2, $Boom3, $Boom4] 

@export var rune_final_scale := 7 
var damage = 10

func _ready():
	show()
	exp_anim.show()
	rune.show()
	
	rune.modulate.a = 0
	rune.scale = Vector2.ZERO 
	rune.rotation_degrees = -180

	exp_anim.play("Attack")
	if particles:
		particles.restart()
	
	
	if sounds.size() > 0:
		var s = sounds.pick_random()
		s.pitch_scale = randf_range(0.8, 1.2)
		s.play()
	
	var t = create_tween().set_parallel(true)

	t.tween_property(rune, "scale", Vector2(rune_final_scale, rune_final_scale), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(rune, "rotation_degrees", 0, 0.3).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	t.tween_property(rune, "modulate:a", 1.0, 0.1)
	
	
	var t_loop = create_tween().set_loops()
	t_loop.tween_property(rune, "scale", Vector2(rune_final_scale * 1.1, rune_final_scale * 1.1), 0.3)
	t_loop.tween_property(rune, "scale", Vector2(rune_final_scale, rune_final_scale), 0.3)
	
	var t_spin = create_tween().set_loops()
	t_spin.tween_property(rune, "rotation_degrees", 360, 4.0).as_relative() # Постоянно медленно крутим
	
	
	exp_anim.animation_finished.connect(func():
		t_loop.kill() 
		var t_out = create_tween().set_parallel(true)
		t_out.tween_property(rune, "scale", Vector2(rune_final_scale * 1.5, rune_final_scale * 1.5), 0.2)
		t_out.tween_property(rune, "modulate:a", 0.0, 0.2)
		t_out.tween_property(self, "modulate:a", 0.0, 0.2)
		t_out.finished.connect(queue_free)
	)
	
	apply_explosion_damage()

func apply_explosion_damage():
	monitoring = true
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	var targets = get_overlapping_bodies()
	for body in targets:
		if body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
			if body.has_method("apply_knockback"):
				body.apply_knockback(global_position, 1000.0)
	
	monitoring = false
