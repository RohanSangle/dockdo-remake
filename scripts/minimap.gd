extends MarginContainer

@export var player: NodePath
@export var zoom = 0.1

@onready var grid = $MarginContainer/Grid
@onready var player_marker = $MarginContainer/Grid/player_marker
@onready var mob_marker = $MarginContainer/Grid/enemy_marker

@onready var icons = {"mob": mob_marker}

var grid_scale
var markers = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _initialize_markers() -> void:
	# Get all objects in the group "minimap_objects" and add their markers
	var map_objects = get_tree().get_nodes_in_group("minimap_objects")
	for item in map_objects:
		if item in markers:
			continue  # Skip if marker already exists
		var new_marker = icons[item.minimap_icon].duplicate()
		grid.add_child(new_marker)
		new_marker.show()
		markers[item] = new_marker


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !player:
		return
	player_marker.rotation = -get_node(player).rotation.y - PI/2
	
	player_marker.position = grid.size/2
	grid_scale = grid.size / (get_viewport_rect().size * zoom)
	
	#var map_objects = get_tree().get_nodes_in_group("minimap_objects")
	#print("Map objects in group: ", map_objects)
	#for item in map_objects:
		#var new_marker = icons[item.minimap_icon].duplicate()
		#grid.add_child(new_marker)
		#new_marker.show()
		#markers[item] = new_marker
		
	_initialize_markers()
	
	for item in markers:
		if not is_instance_valid(item):
			# Clean up if the object is removed
			markers[item].queue_free()
			markers.erase(item)
			continue
		
		var obj_pos = (Vector2(-item.position.x, -item.position.z) - Vector2(-get_node(player).position.x, -get_node(player).position.z)) * grid_scale + grid.size / 2
		
		
		if obj_pos.x < 0 or obj_pos.y < 0 or obj_pos.x > grid.size.x or obj_pos.y > grid.size.y:
			markers[item].hide()
		else:
			markers[item].show()
			# Clamp the position to the grid's rectangle
			obj_pos.x = clamp(obj_pos.x, 0, grid.size.x)
			obj_pos.y = clamp(obj_pos.y, 0, grid.size.y)
			markers[item].position = obj_pos
		
		markers[item].rotation = -item.global_transform.basis.get_euler().y - PI / 2
		# Rotate the marker to match the object's rotation
		#if item.has_method("global_transform"):a
			#markers[item].rotation = -item.global_transform.basis.get_eular().y - PI / 2
			## Debugging output to verify rotations
			#print("Object:", item.name, "Rotation Y:", item.global_transform.basis.get_eular().y, "Marker Rotation:", markers[item].rotation)
	
