extends Node2D

var enemySpawnCooldown = 1;
var enemyAcc = 0.0;
var limitNPC = 200;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
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

	if zone:
		var collision_shape = zone.get_node("Area2D").get_node("CollisionShape2D")
		if collision_shape.shape is RectangleShape2D:
			var rectangle_shape = collision_shape.shape as RectangleShape2D
			var extents = rectangle_shape.extents
			
			# Génère une position aléatoire à l'intérieur de la zone
			
			var random_position = zone.global_position + Vector2(
				randi_range(0, 2*extents.x), #coin supérieur gauche la position globale de la zone
				randi_range(0, 2*extents.y)
			)
			print(-extents.x)
			print(extents.x)

			enemy_instance.global_position = random_position
			get_parent().add_child(enemy_instance)
		else:
			print("CollisionShape2D is not a RectangleShape2D")
	else:
		print("NavZone not found")

	
