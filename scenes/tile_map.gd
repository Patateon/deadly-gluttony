extends Node2D

var player_position = Vector2()
var loaded_chunks = []
var chunk_size = 1
var tile_floor = 0 # ID de la tuile de sol
var tile_decoration = 0 # ID de la tuile pour la surcouche (ex: herbe)
var cell_size = Vector2(32,32)




@onready var floor: TileMapLayer = $floor
@onready var decoration: TileMapLayer = $decoration

func _ready():
	# Calculer la taille du chunk en fonction de l'écran
	var screen_size = get_viewport_rect().size
	var cells_in_viewport_x = ceil(screen_size.x / cell_size.x)
	var cells_in_viewport_y = ceil(screen_size.y / cell_size.y)
	
	# Taille de chunk = taille de l'écran en cellules + 1
	chunk_size = max(cells_in_viewport_x, cells_in_viewport_y) + 1
	
	player_position = get_node("../Player").position
	generate_around_player()

func _process(delta):
	var new_player_position = get_node("../Player").position
	if player_position != new_player_position:
		player_position = new_player_position
		generate_around_player()

# Génération des chunks autour du joueur
func generate_around_player():
	var player_chunk = Vector2(int(player_position.x / (chunk_size * cell_size.x)), int(player_position.y / (chunk_size * cell_size.y)))

	# Générer les chunks autour du joueur (+1 chunk autour du joueur)
	for x in range(player_chunk.x - 2, player_chunk.x + 2):
		for y in range(player_chunk.y - 2, player_chunk.y + 2):
			var chunk = Vector2(x, y)
			if chunk not in loaded_chunks:
				generate_chunk(chunk)
				loaded_chunks.append(chunk)

# Générer les tuiles du sol et les décorations (surcouches)
func generate_chunk(chunk_position):
	for x in range(chunk_size):
		for y in range(chunk_size):
			var tile_pos = Vector2i(chunk_position.x * chunk_size + x, chunk_position.y * chunk_size + y)
			
			# Générer la couche de sol (layer_floor)
			floor.set_cell(tile_pos, tile_floor, Vector2i(6, 20), 0)
			if randi() % 45 == 0 and decoration.get_cell_source_id(tile_pos) == -1 and decoration.get_cell_source_id(tile_pos+ Vector2i(1,1)) == -1 and decoration.get_cell_source_id(tile_pos + Vector2i(1,0)) == -1 and decoration.get_cell_source_id(tile_pos + Vector2i(0,1)) == -1:
				# Sélectionner aléatoirement parmi 5 décorations
				var decoration_type = randi() % 5
				match decoration_type:
					0:
						decoration.set_cell(tile_pos, tile_decoration, Vector2i(0, 0), 0)
						decoration.set_cell(tile_pos + Vector2i(1, 0), tile_decoration, Vector2i(1, 0), 0)
					1:
						decoration.set_cell(tile_pos, tile_decoration, Vector2i(6, 0), 0)
						decoration.set_cell(tile_pos + Vector2i(1, 0), tile_decoration, Vector2i(7, 0), 0)
					2:
						decoration.set_cell(tile_pos, tile_decoration, Vector2i(8, 0), 0)
					3:
						decoration.set_cell(tile_pos, tile_decoration, Vector2i(9, 0), 0)
					4:
						decoration.set_cell(tile_pos, tile_decoration, Vector2i(2, 0), 0)
						decoration.set_cell(tile_pos+ Vector2i(1, 0), tile_decoration, Vector2i(3, 0), 0)
						decoration.set_cell(tile_pos+ Vector2i(0, 1), tile_decoration, Vector2i(2, 1), 0)
						decoration.set_cell(tile_pos+ Vector2i(1, 1), tile_decoration, Vector2i(3, 1), 0)
