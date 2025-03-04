extends State

class_name DeadState

@export var enemy : CharacterBody3D

func Enter():
	#var enemy = get_parent().owner as EnemyShip
	enemy.collision_shape.disabled = true
	enemy.linear_damp = 0.8
	enemy.angular_damp = 0.8
	enemy.freeze = true
	await get_tree().create_timer(3.0).timeout
	spawn_loot()
	enemy.queue_free()

func spawn_loot():
	# Implement loot spawning logic
	pass
