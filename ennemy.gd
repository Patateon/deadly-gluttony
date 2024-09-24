extends CharacterBody2D

var movement_speed: float = 200.0
var attack_distance: float = 1.0
var damage: float = 10.0  
var movement_target_position: Vector2

var life: float = 100.0
var current_life: float = life
var xp_rate: float = 1 # Taux de chance de générer l'objet d'expérience
var xp_value: float = 3 

@onready var navigation_agent: NavigationAgent2D = $EnemyNav
@onready var area2d: Area2D = $EnemyArea
var player = null  

func _ready():
	navigation_agent.path_desired_distance = 100.0
	navigation_agent.target_desired_distance = 30.0
	call_deferred("actor_setup")

	area2d.monitoring = true
	area2d.connect("area_entered", Callable(self, "_on_Area2D_area_entered"))

	player = get_node("/root/World/Player")
	if player:
		player.connect("player_died", Callable(self, "_on_Player_died"))

func actor_setup():
	await get_tree().physics_frame
	update_movement_target()

func update_movement_target():
	if player and is_instance_valid(player) and player.is_alive: 
		movement_target_position = player.global_position
		set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(delta: float) -> void:
	if not player or not is_instance_valid(player) or not player.is_alive:  
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player > attack_distance:
		update_movement_target()

		if navigation_agent.is_navigation_finished():
			#print("Navigation finished. Recalculating target.")
			return

		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()

		velocity = current_agent_position.direction_to(next_path_position) * movement_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_Area2D_area_entered(area: Area2D):
	print("Area entered:", area.name)
	print("Groups of the entered area:")
	for group in area.get_groups():
		print(group)
	if area.is_in_group("Player"):
		print("player")
		var player = area.get_parent()  
		print("Player node:", player)
		if player and player.has_method("take_damage"):
			print("Player has take_damage method")
			player.take_damage(damage)

func _on_Player_died():
	print("Player died")
	player = null  

func take_damage(amount: float):
	current_life -= amount
	print(current_life)
	if current_life <= 0:
		die() 
		
func die():
	if randi() % 100 < int(xp_rate * 100):
		spawn_experience_item()
	queue_free()  

func spawn_experience_item():
	var experience_scene = preload("res://experience_item.tscn")  
	var experience_instance = experience_scene.instantiate()
	experience_instance.global_position = global_position  
	experience_instance.set_xp_value(xp_value)
	get_parent().add_child(experience_instance)
