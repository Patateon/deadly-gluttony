extends Node2D
static var dead_enemy_since_start = 0;
var enemySpawnCooldown = 1;
var enemyAcc = 0.0;
var limitNPC = 200;
var minDistanceFromPlayer = 400

func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	enemyAcc += delta
	if (enemyAcc > enemySpawnCooldown):
		enemyAcc = 0
		print(limitNPC)
		print(get_tree().get_nodes_in_group("NPC").size())
		if (get_tree().get_nodes_in_group("NPC").size() < limitNPC):
			for i in range(randi_range(3, 5)):
				print("Creating enemy")
				createEnemy()
			
			
func createEnemy():
	var enemy_scene = preload("res://scenes/enemy.tscn")
	var enemy_instance = enemy_scene.instantiate()
	var zone = get_tree().get_first_node_in_group("NavZone")
	var player = get_tree().get_first_node_in_group("Player")

	enemy_instance.connect("enemy_died", Callable(self, "_on_Enemy_died"))
  
	if zone and player:
		var collision_shape = zone.get_node("Area2D").get_node("CollisionShape2D")
		if collision_shape.shape is RectangleShape2D:
			var rectangle_shape = collision_shape.shape as RectangleShape2D
			var extents = rectangle_shape.extents

			var random_position
			var is_valid_position = false

			while not is_valid_position:
				random_position = zone.global_position + Vector2(#zone global pos donne le coin supérieur gauche
					randi_range(0, 2 * extents.x),
					randi_range(0, 2 * extents.y)
				)
				if random_position.distance_to(player.global_position) >= minDistanceFromPlayer:
					is_valid_position = true

			enemy_instance.global_position = random_position
			get_parent().add_child(enemy_instance)
		else:
			print("CollisionShape2D is not a RectangleShape2D")
	else:
		print("NavZone or Player not found")
		
func _on_Enemy_died():
	dead_enemy_since_start+=1
