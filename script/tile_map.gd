extends Node2D

var player_position = Vector2()
var loaded_chunks = []
var chunk_size = 1
var tile_floor = 0 
var tile_decoration = 0 
var cell_size = Vector2i(32,32)
var player = null  

@onready var floor: TileMapLayer = $floor
@onready var decoration: TileMapLayer = $decoration

func _ready():
	
	var screen_size = get_viewport_rect().size
	var cells_in_viewport_x = ceil(screen_size.x / cell_size.x)
	var cells_in_viewport_y = ceil(screen_size.y / cell_size.y)
	chunk_size = max(cells_in_viewport_x, cells_in_viewport_y) + 1
	player = get_tree().get_first_node_in_group("Player")
	if player:
		player.connect("player_died", Callable(self, "_on_Player_died"))
	player_position = get_node("../Player").position
	generate_around_player()

func _process(delta):
	if player:  
		var new_player_position = get_node("../Player").position
		if player_position != new_player_position:
			player_position = new_player_position
			generate_around_player()


func generate_around_player():
	var player_chunk = Vector2(int(player_position.x / (chunk_size * cell_size.x)), int(player_position.y / (chunk_size * cell_size.y)))
	for x in range(player_chunk.x - 2, player_chunk.x + 2):
		for y in range(player_chunk.y - 2, player_chunk.y + 2):
			var chunk = Vector2(x, y)
			if chunk not in loaded_chunks:
				generate_chunk(chunk)
				loaded_chunks.append(chunk)
				
func create_texture_rect(position: Vector2i, texture_path: String, z_index: int, sens: int):
	var texture_rect = TextureRect.new()
	texture_rect.texture = load(texture_path)
	texture_rect.position = position * cell_size   # Position en pixels sur la carte
	texture_rect.z_index = z_index  # Affecte la profondeur d'affichage (plus grand = plus "devant")
	if (sens):
		texture_rect.flip_h=true
	add_child(texture_rect)  # Ajouter le TextureRect à la scène
	return texture_rect

func generate_chunk(chunk_position):
	for x in range(chunk_size):
		for y in range(chunk_size):
			var tile_pos = Vector2i(chunk_position.x * chunk_size + x, chunk_position.y * chunk_size + y)
			floor.set_cell(tile_pos, tile_floor, Vector2i(6, 20), 0)
			# Créer des décorations avec des TextureRect
			if randi() % 555 == 0:
				var decoration_type = randi() % 5
				var sens = randi() % 2
				match decoration_type:
					0:
						create_texture_rect(tile_pos, "res://assets/sprites/bilboardkfc.png",5,0) 
					1:
						create_texture_rect(tile_pos, "res://assets/sprites/bilboardsub.png",5,0) 
					2:
						create_texture_rect(tile_pos, "res://assets/sprites/bilboardmcdo.png",5,sens) 
					3:
						create_texture_rect(tile_pos, "res://assets/sprites/bilboardtacos.png",5,sens) 
					4:
						create_texture_rect(tile_pos, "res://assets/sprites/bilboardburgouzz.png",5,0) 
				#create_texture_rect(tile_pos, "res://assets/sprites/bilboard.png",5)



func _on_Player_died():
	print("Player died.")
	player = null  
