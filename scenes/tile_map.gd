extends Node2D

var player_position = Vector2()
var loaded_chunks = []
var chunk_size = 8
var tile_floor = 0 # ID de la tuile de sol
var tile_decoration = 1 # ID de la tuile pour la surcouche (ex: herbe)
var cell_size = Vector2(32,32)
# Spécifie l'index de la couche (layer) pour chaque type de tuile
var layer_floor = 0
var layer_decoration = 1

@onready var floor: TileMapLayer = $floor
@onready var decoration: TileMapLayer = $decoration

func _ready():
	player_position = get_node("../Player").position

func _process(delta):
	var new_player_position = get_node("../Player").position
	if player_position != new_player_position:
		player_position = new_player_position
		generate_around_player()

# Génération des chunks autour du joueur
func generate_around_player():
	var player_chunk = Vector2(int(player_position.x / (chunk_size * cell_size.x)), int(player_position.y / (chunk_size * cell_size.y)))

	for x in range(player_chunk.x - 1, player_chunk.x + 2):
		for y in range(player_chunk.y - 1, player_chunk.y + 2):
			var chunk = Vector2(x, y)
			if chunk not in loaded_chunks:
				generate_chunk(chunk)
				loaded_chunks.append(chunk)

# Générer les tuiles du sol et les décorations (surcouches)
func generate_chunk(chunk_position):
	for x in range(chunk_size):
		for y in range(chunk_size):
			var tile_pos = Vector2(chunk_position.x * chunk_size + x, chunk_position.y * chunk_size + y)
			
			
			# Générer la couche de sol (layer_floor)
			floor.set_cell(tile_pos.x, tile_pos.y, layer_floor, tile_floor)
			
			# Ajouter des décorations sur la couche supérieure de manière aléatoire (layer_decoration)
			if randi() % 10 == 0:  # 10% de chance d'ajouter une décoration
				decoration.set_cell(tile_pos.x, tile_pos.y, layer_decoration, tile_decoration)
