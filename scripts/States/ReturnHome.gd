extends State

class_name ReturnHomeState

@export var enemy : CharacterBody3D

func physics_update(delta: float):
	#var enemy = get_parent().owner as EnemyShip
	if enemy.is_dead:
		Transitioned.emit(self, "Dead")
		return
	
	var target_angle = enemy.get_angle_to_target(enemy.home_position)
	var current_angle = enemy.rotation.y
	var angle_diff = wrapf(target_angle - current_angle, -PI, PI)
	
	var steer = clamp(angle_diff * enemy.steer_force, -1.0, 1.0)
	enemy.apply_torque_impulse(Vector3.UP * steer * delta * 100)
	var forward_force = enemy.global_transform.basis.z.normalized() * enemy.motor_force * 100
	enemy.apply_central_force(-forward_force)
	
	if enemy.calculate_distance_to_home() < 10.0:
		Transitioned.emit(self, "Idle")
