extends State
class_name Idle

@export var enemy : CharacterBody3D


var player : CharacterBody3D
var spawn_grace_time := 1.0  # 1 second of grace period
var timer := 0.0
var yellow_alert_played := false
@onready var yellow_alert_sprite = $"../../yellowalert"  # Reference to the Sprite3D node
@onready var animation_player = $"../../AnimationPlayer"  # Reference to the AnimationPlayer

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	timer = spawn_grace_time
	yellow_alert_sprite.visible = false  # Ensure yellow alert sprite is hidden

func Physics_Update(delta: float):
	
	if timer > 0:
		timer -= delta
		return
	
	if timer <= 0 and player_in_range() and not yellow_alert_played:
		play_yellow_alert()
		return
		
	# Wait for yellow alert animation to finish before transitioning
	if yellow_alert_played and not animation_player.is_playing():
		Transitioned.emit(self, "Chase")
		yellow_alert_sprite.hide()
	

func player_in_range() -> bool:
	var direction = player.global_position - enemy.global_position
	return direction.length() <= 15

func play_yellow_alert():
	yellow_alert_sprite.show()
	animation_player.play("yellowAlert")
	yellow_alert_played = true

func Exit():
	yellow_alert_sprite.hide()
