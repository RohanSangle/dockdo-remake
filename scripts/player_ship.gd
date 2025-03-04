extends CharacterBody3D

class_name Player

var max_speed = 30.0
var acceleration = 0.1
var forward_speed = 0.0
var rudder_speed = 1.00
var rudder_input = 0.0
var input_response = 8.0

@export var max_health := 100.0

var current_health: float
var tilt_speed = 1.0
var tilt_input = 0.0
var tilt_recovery_speed = 2.0

func _ready():
	current_health = max_health

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		#velocity += get_gravity() * delta
		velocity.y = -9.8*delta
	else:
		velocity.y = 0
	
	
	get_input(delta)
	
	#steering rotation
	transform.basis = transform.basis.rotated(transform.basis.y, rudder_input * rudder_speed * delta)
	
	# Tilt rotation
	if tilt_input != 0:
		transform.basis = transform.basis.rotated(transform.basis.z, tilt_input * tilt_speed * delta)
	# Reset tilt over time
	reset_tilt(delta)
	
	# Ensure the ship doesn't leave the ground
	ensure_ground_alignment()
	
	#transform.basis = transform.basis.rotated(transform.basis.z, tilt_input * tilt_speed * delta)
	transform.basis = transform.basis.orthonormalized()
	
	velocity = transform.basis.z * forward_speed
	move_and_slide()
	$Camera_controller.position = lerp($Camera_controller.position,position,0.05)


func get_input(delta):
	
	if Input.is_action_pressed("speed_up"):
		forward_speed = lerp(forward_speed, max_speed, acceleration * delta)
	if Input.is_action_pressed("slow_down"):
		forward_speed = lerp(forward_speed, 0.0, acceleration * delta)
	
	rudder_input = lerp(rudder_input, Input.get_action_strength("rudder_left") - Input.get_action_strength("rudder_right"), input_response * delta)
	#tilt_input = Input.get_action_strength("rudder_left") - Input.get_action_strength("rudder_right")
	
	var rudder_strength = Input.get_action_strength("rudder_left") - Input.get_action_strength("rudder_right")
	if rudder_strength != 0:
		tilt_input = rudder_strength  # Apply tilt based on rudder input
	else:
		tilt_input = 0.0  # Gradually reset tilt

func reset_tilt(delta):
	# Gradually reset the tilt to an upright position
	var target_basis = Basis()
	target_basis.y = Vector3.UP  # Upward vector
	target_basis.z = transform.basis.z.normalized()
	target_basis.x = target_basis.y.cross(target_basis.z).normalized()
	target_basis.z = target_basis.x.cross(target_basis.y).normalized()

	# Interpolate between current basis and upright basis
	transform.basis = transform.basis.slerp(target_basis, tilt_recovery_speed * delta)

func ensure_ground_alignment():
	# Ensure the position.y stays at a consistent height (optional for a flat ground)
	position.y = 0

func take_damage(amount: float):
	print("Player took damage:", amount)  # Debug print
	current_health -= amount
	if current_health <= 0:
		# Handle player death
		print("Player died!")
	else:
		print("Player health:", current_health)
