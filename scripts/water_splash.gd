extends Node3D

@onready var splash_particles = $SplashParticles

func _ready():
	splash_particles.emitting = true
	# Wait for particles to finish (lifetime + a small buffer)
	await get_tree().create_timer(splash_particles.lifetime + 0.1).timeout
	queue_free()  # Remove the splash from the scene
