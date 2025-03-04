extends Node3D


var enemyShip = preload("res://scenes/enemy_ship.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the Timer's timeout signal to a spawn function
	$EnemyContainer/spawnEnemy.timeout.connect(_on_spawn_enemy_timeout)
	$EnemyContainer/spawnEnemy.start()  # Start the timer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Function to handle enemy spawning
func _on_spawn_enemy_timeout():
	var enemy_instance = enemyShip.instantiate()
	$EnemyContainer.add_child(enemy_instance)
	var spawn_position = get_random_spawn_position()
	enemy_instance.global_transform.origin = spawn_position
	#print("Spawning enemy: ", enemy_instance)

# Generate a random spawn position outside the camera's view
func get_random_spawn_position() -> Vector3:
	var player_ship = $PlayerShip  # Replace with your actual PlayerShip node path
	var camera = player_ship.get_node("Camera_controller/Camera_target/Camera3D")
	var cam_transform = camera.global_transform
	#var offset = cam_transform.basis.z * -10  # Spawn 50 units behind the camera
	#var position = cam_transform.origin + offset
	## Ensure enemy is at ground level
	#position.y = 0
	#return position
	
	# Randomly pick a side (left, right, behind)
	var directions = [
		-cam_transform.basis.x,  # Left
		cam_transform.basis.x,   # Right
		-cam_transform.basis.z   # Behind
	]
	var random_direction = directions[randi() % directions.size()]
	# Spawn at a random distance within a range
	var min_distance = 40
	var max_distance = 50
	var spawn_distance = randf_range(min_distance, max_distance)
	# Calculate spawn position
	var spawn_position = cam_transform.origin + random_direction * spawn_distance
	# Keep the spawn position at ground level
	spawn_position.y = 0
	return spawn_position
