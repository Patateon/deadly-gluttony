extends Node2D

var player_position = Vector2()
var loaded_chunks = []
var chunk_size = 1
var tile_floor = 0 
var tile_decoration = 0 
var cell_size = Vector2i(32,32)
var player = null  
var noise := FastNoiseLite.new()

@onready var floor: TileMapLayer = $floor
@onready var decoration: TileMapLayer = $decoration

func _ready():
	# Définir les paramètres du bruit
	noise.seed = randi()  # Générer une graine aléatoire
	noise.frequency = 0.1 # Réduire la fréquence pour des chemins plus lents et lissés
	noise.noise_type = FastNoiseLite.TYPE_PERLIN  # Utiliser le bruit de Perlin
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM  # Utiliser FBM pour des transitions plus douces
	noise.fractal_octaves = 15 # Plus d'octaves pour ajouter des détails lissés
	noise.fractal_gain = 0.45  # Contrôle le lissage des octaves
	noise.fractal_lacunarity = 0.33 # Plus bas pour des détails plus cohérents entre les octaves
	
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
			# Calculer la valeur de bruit pour ce point (x, y)
			var noise_value = noise.get_noise_2d(tile_pos.x, tile_pos.y)
			# Si la valeur du bruit est inférieure à un certain seuil, on place un chemin
			if noise_value > 0.2: 
				var type_cell = randi() % 2
				match type_cell:
					0:
						floor.set_cell(tile_pos, tile_floor, Vector2i(5, 20), 0)  # Tile du chemin
					1:
						floor.set_cell(tile_pos, tile_floor, Vector2i(6, 20), 0)  # Tile du chemin
			#elif noise_value > 0.2: 
				#var type_cell = randi() % 15
				#if( type_cell == 0):
					#floor.set_cell(tile_pos, tile_floor, Vector2i(6, 20), 0)  # Tile du chemin
				#else:
					#floor.set_cell(tile_pos, tile_floor, Vector2i(5, 20), 0)  # Tile du chemin
			#elif noise_value > 0.10: 
				#var type_cell = randi() % 19
				#if( type_cell == 0):
					#floor.set_cell(tile_pos, tile_floor, Vector2i(6, 20), 0)  # Tile du chemin
				#else:
					#floor.set_cell(tile_pos, tile_floor, Vector2i(5, 20), 0)  # Tile du chemin
			elif noise_value > 0.0: 
				floor.set_cell(tile_pos, tile_floor, Vector2i(5,20), 0)  # Tile du chemin
			elif noise_value > -0.10: 
				floor.set_cell(tile_pos, tile_floor, Vector2i(3, 19), 0)  # Tile du chemin
			elif noise_value > -0.20: 
				floor.set_cell(tile_pos, tile_floor, Vector2i(3, 18), 0)  # Tile du chemin
			elif noise_value > -0.30: 
				floor.set_cell(tile_pos, tile_floor, Vector2i(3, 16), 0)  # Tile du chemin
			else:
				floor.set_cell(tile_pos, tile_floor, Vector2i(1, 19), 0)  # Tile du reste
			
			# Créer des décorations avec des TextureRect
			if noise_value > 0.4 and randi() % 215 == 0:
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
