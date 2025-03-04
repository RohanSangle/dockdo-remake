extends State
class_name Follow

@export var enemy : CharacterBody3D

@export var move_speed := 4.0
@export var steer_force: float = 5.0
@export var look_ahead: float = 15.0
@export var num_rays: int = 16
@export var tilt_amount := 15.0  # Maximum tilt angle (in degrees) for roll

var player : CharacterBody3D
var ray_directions: Array = []
var interest: Array = []
var danger: Array = []
var chosen_dir: Vector3 = Vector3.ZERO
var red_alert_played := false
@onready var red_alert_sprite = $"../../redalert"
@onready var animation_player = $"../../AnimationPlayer"  # Reference to the AnimationPlayer

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	_initialize_rays()
	red_alert_sprite.visible = true
	animation_player.play("redAlert")  # Play red alert animation
	red_alert_played = true

func _initialize_rays():
	# Initialize ray directions evenly distributed in a 3D plane
	ray_directions.resize(num_rays)
	interest.resize(num_rays)
	danger.resize(num_rays)
	
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector3(cos(angle), 0, sin(angle)).normalized()
	#interest.resize(num_rays)
	#danger.resize(num_rays)

func Physics_Update(delta: float):
	
	#set_interest()
	#set_danger()
	#choose_direction()
	
	if red_alert_played and not animation_player.is_playing():
		red_alert_sprite.visible = false
	
	#var direction = (target_position - enemy.global_position).normalized()
	#var desired_velocity = chosen_dir * move_speed
	#enemy.velocity = enemy.velocity.lerp(desired_velocity, steer_force * delta)
	
	# Update rotation and tilt based on chosen direction
	#if chosen_dir != Vector3.ZERO:
		#update_rotation_and_tilt(delta)
	
	#var direction = player.global_position - enemy.global_position
	#if direction.length() > 30:
		#Transitioned.emit(self, "Idle")
	#if direction.length() <= 15:
		#Transitioned.emit(self, "Surround")
	
	update_steering(delta)
	apply_movement(delta)
	check_transitions()

func update_steering(delta):
	set_interest()
	set_danger()
	choose_direction()
	update_rotation_and_tilt(delta)

func set_interest():
	# Set interest based on the player's direction
	if player:
		var player_direction = (player.global_position - enemy.global_position).normalized()
		for i in num_rays:
			var d = ray_directions[i].dot(player_direction)
			interest[i] = max(0, d)
	else:
		set_default_interest()

func set_default_interest():
	# Default interest prioritizes forward movement
	for i in num_rays:
		var forward_direction = enemy.global_transform.basis.z
		var d = ray_directions[i].dot(forward_direction)
		interest[i] = max(0, d)

func set_danger():
	# Cast rays in each direction to detect obstacles
	var space_state = enemy.get_world_3d().direct_space_state
	for i in num_rays:
		var ray_start = enemy.global_position
		var ray_end = ray_start + (ray_directions[i] * look_ahead)
		
		#var result = space_state.intersect_ray(ray_start, ray_end, [enemy])
		# Create a PhysicsRayQueryParameters3D object
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = ray_start
		ray_query.to = ray_end
		
		var enemies = get_tree().get_nodes_in_group("Enemies")  # Assuming you add all enemies to a group named "Enemies"
		ray_query.exclude = [enemy] + enemies  # Exclude the enemy itself
		# Use intersect_ray with the query object
		var result = space_state.intersect_ray(ray_query)
		
		#danger[i] = 1.0 if result else 0.0
		if result:
			var hit_distance = (result.position - ray_start).length()
			danger[i] = 1.0 - clamp(hit_distance / look_ahead, 0.0, 1.0)  # Scale danger based on proximity
		else:
			danger[i] = 0.0  # No danger if no obstacle is detected

func choose_direction():
	# Eliminate interest in directions with danger
	#for i in num_rays:
		#if danger[i] > 0.0:
			#interest[i] = 0.0
	for i in num_rays:
		interest[i] *= 1.0 - danger[i]
	
	# Combine interest to choose the best direction
	chosen_dir = Vector3.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interest[i]
	chosen_dir = chosen_dir.normalized()

func apply_movement(delta):
	var desired_velocity = chosen_dir * move_speed
	enemy.velocity = enemy.velocity.lerp(desired_velocity, steer_force * delta)

func update_rotation_and_tilt(delta: float):
	# Calculate yaw (rotation around Y-axis)
	var target_yaw = atan2(chosen_dir.x, chosen_dir.z)
	enemy.rotation.y = lerp_angle(enemy.rotation.y, target_yaw, steer_force * delta)
	# Calculate tilt (rotation around X-Z plane)
	
	#var tilt = -chosen_dir.x * deg_to_rad(tilt_amount)
	var tilt = clamp(-chosen_dir.x * deg_to_rad(tilt_amount), -0.2, 0.2)
	enemy.rotation.z = lerp(enemy.rotation.z, tilt, steer_force * delta)

func check_transitions():
	#if !is_instance_valid(enemy.target):
		#Transitioned.emit(self, "Idle")
		#return
	
	#var distance = enemy.global_position.distance_to(enemy.target.global_position)
	var distance = player.global_position - enemy.global_position
	
	if distance.length() <= enemy.atk_range:
		Transitioned.emit(self, "Attack")
	#elif !enemy.is_pirate && enemy.global_position.distance_to(enemy.home_position) > 40.0:
		#Transitioned.emit(self, "ReturnHome")

func Exit():
	enemy.velocity = Vector3()
