extends CharacterBody3D

@export var current_hp: int
@export var atk: int
@export var is_dead: bool = false
@export var lock_on: bool = false
@export var is_pirate: bool = false
@export var is_arena: bool = false
@export var motor_force: float
@export var steer_force: float
@export var atk_range: float
@export var detect_range: float

var player: Node3D
var home_position: Vector3

@onready var state_machine:= $StateMachine

var minimap_icon = "mob"
@onready var animation_player = $AnimationPlayer

func _ready():
	add_to_group("minimap_objects")
	animation_player.play("Spawn")
	player = get_tree().get_first_node_in_group("Player")
	init(1) # Initialize with appropriate tier level


func init(tier_level: int):
	# Initialize ship stats based on tier level
	current_hp = 100
	atk = 15*tier_level
	motor_force = 4.0*tier_level
	steer_force = 3.0*tier_level
	atk_range = 15.0*tier_level
	detect_range = 30.0

func _physics_process(delta: float) -> void:
	global_position.y = 0.0
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	
	move_and_slide()

func take_damage(amount: int):
	if is_dead: return
	current_hp -= amount
	if current_hp <= 0:
		#die()
		is_dead = true
		state_machine.transition_to("Dead")

func calculate_distance_to_player() -> float:
	return global_position.distance_to(player.global_position)

func calculate_distance_to_home() -> float:
	return global_position.distance_to(home_position)

func get_angle_to_target(target_pos: Vector3) -> float:
	var direction = (target_pos - global_position).normalized()
	return atan2(direction.x, direction.z)
