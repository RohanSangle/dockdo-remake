extends Node3D

@export var fire_range := 15.0
@export var reload_time := 2.8
@export var angle_range := 80.0
@export var muzzle_speed := 20.0
@export var is_enemy := true
@export var gravity := 9.8

var max_rotation_angle := 40.0
var can_fire := true
var current_target: Node3D = null
var projectile_pool: Array = []
var max_pool_size := 10
var rotation_speed := 2.0
var base_rotation: Vector3
var detection_angle = 25.0

@onready var debug_lines = $DebugLines
@onready var immediate_mesh = debug_lines.mesh as ImmediateMesh
@onready var muzzle := $muzzle
@onready var reload_timer := $ReloadTimer

func _ready():
	base_rotation = rotation
	initialize_pool()
	reload_timer.wait_time = reload_time
	reload_timer.one_shot = true
	reload_timer.connect("timeout", Callable(self, "_on_reload_timer_timeout"))

func initialize_pool():
	var projectile_scene = load("res://scenes/cannon_ball.tscn")
	for i in max_pool_size:
		var projectile = projectile_scene.instantiate()
		projectile.visible = false
		get_tree().root.call_deferred("add_child", projectile)
		projectile_pool.append(projectile)

func _process(delta):
	var player = get_tree().get_first_node_in_group("Player")
	if not player or not is_instance_valid(player):
		current_target = null
		return
	
	# Clear the previous frame's mesh
	immediate_mesh.clear_surfaces()
	
	# Begin a new surface for drawing lines
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	
	var current_rotation = rotation
	rotation = base_rotation
	var base_forward = global_transform.basis.x.normalized()
	var local_up = global_transform.basis.y.normalized()
	
	var detection_left_dir = base_forward.rotated(local_up, deg_to_rad(-detection_angle))
	var detection_right_dir = base_forward.rotated(local_up, deg_to_rad(detection_angle))
	
	# Define aiming arc (±40 degrees)
	var aiming_left_dir = base_forward.rotated(local_up, deg_to_rad(-max_rotation_angle))
	var aiming_right_dir = base_forward.rotated(local_up, deg_to_rad(max_rotation_angle))
	
	# Draw detection arc boundaries (yellow)
	immediate_mesh.surface_set_color(Color.YELLOW)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)
	immediate_mesh.surface_add_vertex(detection_left_dir * fire_range)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)
	immediate_mesh.surface_add_vertex(detection_right_dir * fire_range)
	
	# Draw aiming arc boundaries (blue)
	immediate_mesh.surface_set_color(Color.BLUE)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)
	immediate_mesh.surface_add_vertex(aiming_left_dir * fire_range)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)
	immediate_mesh.surface_add_vertex(aiming_right_dir * fire_range)
	
	# Restore the cannon's rotation
	rotation = current_rotation
	
	# Draw current aiming direction (red)
	var current_forward = global_transform.basis.x.normalized()
	immediate_mesh.surface_set_color(Color.RED)
	immediate_mesh.surface_add_vertex(Vector3.ZERO)
	immediate_mesh.surface_add_vertex(current_forward * fire_range)
	
	# End the surface
	immediate_mesh.surface_end()
	
	# Check distance to player
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player > fire_range:
		current_target = null
		return
	
	# Calculate direction to player
	var to_player = (player.global_position - global_position).normalized()
	
	# Calculate angle to player relative to base forward direction
	var angle_to_player = rad_to_deg(base_forward.signed_angle_to(to_player, local_up))
	
	# Check if player is within the 50-degree detection arc
	if abs(angle_to_player) <= detection_angle:
		# Player is within detection arc, set as target
		current_target = player
		
		var desired_angle_deg = clamp(angle_to_player, -max_rotation_angle, max_rotation_angle)
		var target_rotation_y = base_rotation.y + deg_to_rad(desired_angle_deg)
		
		rotation.y = lerp_angle(rotation.y, target_rotation_y, rotation_speed * delta)
		
		# Fire if conditions are met
		if can_fire and abs(rotation.y - target_rotation_y) < 0.1:
			fire_at()
	else:
		# Player is outside detection arc
		current_target = null
		

func fire_at():
	if not can_fire:
		return
	var projectile = get_projectile_from_pool()
	if projectile:
		setup_projectile(projectile)
		start_reload()

func setup_projectile(projectile: Node3D):
	#pure physics
	projectile.global_position = muzzle.global_position  # Use position directly
	projectile.global_rotation = muzzle.global_rotation  # Set rotation separately
	
	#projectile.global_transform = muzzle.global_transform
	projectile.visible = true
	var player = get_tree().get_first_node_in_group("Player")
	var p_t = player.global_position  # Target position
	var p_m = muzzle.global_position  # Muzzle position
	var d_vec = p_t - p_m  # Vector to target

	var d_xz = Vector2(d_vec.x, d_vec.z).length()  # Horizontal distance
	var h = d_vec.y  # Height difference
	var v = muzzle_speed  # Initial speed

	var velocity: Vector3
	if d_xz > 0.01:  # Prevent division by zero
		# Coefficients for quadratic equation to find tan(θ)
		var a = gravity * d_xz * d_xz / (2 * v * v)
		var b = -d_xz
		var c = h + a
		var delta = b * b - 4 * a * c
		
		if delta >= 0:
			var sqrt_delta = sqrt(delta)
			var u1 = (-b - sqrt_delta) / (2 * a)
			var u2 = (-b + sqrt_delta) / (2 * a)
			var theta1 = atan(u1)
			var theta2 = atan(u2)
			# Choose the smaller angle for a more direct shot
			var theta = theta1 if abs(theta1) < abs(theta2) else theta2
			
			# Compute launch direction in global space
			var h_dir = Vector3(d_vec.x, 0, d_vec.z).normalized()  # Horizontal direction
			var d_launch = h_dir * cos(theta) + Vector3(0, sin(theta), 0)
			velocity = v * d_launch
		else:
			# If target is unreachable, fire at 45 degrees
			var theta = deg_to_rad(45)
			var h_dir = Vector3(d_vec.x, 0, d_vec.z).normalized()
			var d_launch = h_dir * cos(theta) + Vector3(0, sin(theta), 0)
			velocity = v * d_launch
	else:
		# If player is directly above/below, fire vertically
		velocity = Vector3(0, v if h > 0 else -v, 0)

	projectile.launch(velocity, is_enemy)

func get_projectile_from_pool():
	for p in projectile_pool:
		if !p.is_active:
			return p
	return null

func start_reload():
	can_fire = false
	reload_timer.start(reload_time)

func _on_reload_timer_timeout():
	can_fire = true
