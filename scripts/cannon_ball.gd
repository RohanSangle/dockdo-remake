extends RigidBody3D

@export var water_level := 0.06
@export var lifespan := 4.0
@export var damage := 15

var is_active := false
var is_enemy_projectile := true
var hit_something := false

@onready var mesh := $ball
@onready var trail_particles := $TrailParticles
const WATER_SPLASH = preload("res://effects/water_splash.tscn")
#@onready var explosion_particles := preload("res://effects/explosion.tscn")

func _ready():
	# Connect the body_entered signal to handle collisions
	connect("body_entered", Callable(self, "_on_body_entered"))
	# Disable physics process until the cannonball is launched
	set_physics_process(false)

func launch(velocity: Vector3, enemy_projectile: bool):
	is_active = true
	is_enemy_projectile = enemy_projectile
	linear_velocity = velocity  # Set the pre-calculated velocity
	gravity_scale = 1.0
	trail_particles.emitting = true
	$LifeTimer.start(lifespan)
	set_physics_process(true)
	

func _physics_process(delta):
	if !is_active: 
		return
	
	# Water impact check
	if global_position.y <= water_level and !hit_something:
		handle_water_impact()
	

func _on_body_entered(body):
	print("Cannonball hit: ", body.name)
	if !is_active:
		return
	# Handle collisions with the player or enemies
	if is_enemy_projectile and body.is_in_group("Player"):
		body.take_damage(damage)
		deactivate()
	#elif !is_enemy_projectile and body.is_in_group("Enemy"):
		#body.take_damage(damage)
		#deactivate()
	# Optionally handle other collisions (e.g., environment)
	else:
		deactivate()

func handle_water_impact():
	hit_something = true
	var splash = WATER_SPLASH.instantiate()
	get_tree().root.add_child(splash)  # Add to root or a specific effects node
	splash.global_position = self.global_position  # Position at cannonball's impact point
	deactivate()

func deactivate():
	linear_velocity = Vector3.ZERO
	trail_particles.emitting = false
	mesh.visible = false
	is_active = false
	hit_something = false
	$LifeTimer.stop()
	set_physics_process(false)

func _on_life_timer_timeout():
	deactivate()
