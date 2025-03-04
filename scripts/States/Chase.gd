extends State

class_name ChaseState

@export var enemy : CharacterBody3D
var attack_cooldown: float = 3.0
var current_cooldown: float = 0.0
var circle_radius: float = 7.0
var circle_speed: float = 2.0
var circle_angle: float = 0.0
@export var tilt_amount := 15.0

var red_alert_played := false
@onready var red_alert_sprite = $"../../redalert"
@onready var animation_player = $"../../AnimationPlayer"

func Enter():
	red_alert_sprite.visible = true
	animation_player.play("redAlert")  # Play red alert animation
	red_alert_played = true

func Physics_Update(delta: float):
	
	if red_alert_played and not animation_player.is_playing():
		red_alert_sprite.visible = false
	
	if enemy.is_dead:
		Transitioned.emit(self, "Dead")
		return
		
	var distance_to_player = enemy.calculate_distance_to_player()
	var distance_to_home = enemy.calculate_distance_to_home()
	
	# Check if should return home
	if !enemy.is_pirate && distance_to_home > 50.0:
		Transitioned.emit(self, "ReturnHome")
		return
	
	#print("distance to player: ", distance_to_player )
	
	# Movement logic
	if distance_to_player > enemy.atk_range:
		# Approach player
		var target_angle = enemy.get_angle_to_target(enemy.player.global_position)
		apply_movement(target_angle, enemy.motor_force, delta)
	else:
		# Circle around player
		circle_angle += circle_speed * delta
		var offset = Vector3(sin(circle_angle) * circle_radius, 0, cos(circle_angle) * circle_radius)
		var target_pos = enemy.player.global_position + offset
		var target_angle = enemy.get_angle_to_target(target_pos)
		apply_movement(target_angle, enemy.motor_force * 0.8, delta)
	

func apply_movement(target_angle: float, speed: float, delta: float):
	var current_angle = enemy.rotation.y
	var angle_diff = wrapf(target_angle - current_angle, -PI, PI)
	
	# Apply steering
	var steer = clamp(angle_diff * enemy.steer_force, -1.0, 1.0)
	var rotation_change = steer * delta * 3.0
	enemy.rotation.y += rotation_change
	
	# Apply tilt (banking effect)
	var max_tilt_angle = deg_to_rad(tilt_amount)  # Maximum tilt angle, adjust as needed
	var tilt = steer * max_tilt_angle
	enemy.rotation.z = lerp(enemy.rotation.z, tilt, enemy.steer_force * delta)
	
	# Apply forward force
	var forward_direction = enemy.global_transform.basis.z.normalized()
	enemy.velocity = forward_direction * speed
