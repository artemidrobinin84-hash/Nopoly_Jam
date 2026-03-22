extends GPUParticles2D

func _ready():
	
	emitting = false 
	one_shot = true
	
	
	restart() 
	emitting = true
	
	
	var total_time = lifetime + 0.5 
	get_tree().create_timer(total_time).timeout.connect(queue_free)
