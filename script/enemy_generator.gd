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
			for i in range(randi_range(1, 3)):
				print("Creating enemy")
				createEnemy()
			
			
func createEnemy():
	var enemy_scene = preload("res://scenes/enemy.tscn")
	var enemy_instance = enemy_scene.instantiate()
	var player = get_tree().get_nodes_in_group("Player")[0]
	#enemy_instance.position = player + Vector2(rand)
	enemy_instance.global_position = Vector2(global_position[0] + randi_range(0, 3),
											 global_position[1] + randi_range(0, 3))
	get_parent().add_child(enemy_instance)
	
