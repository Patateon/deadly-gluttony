extends CharacterBody2D

var movement_speed: float = 150.0
var attack_distance: float = 1.0
var damage: float = 5.0  
var movement_target_position: Vector2

var life: float = 10.0
var current_life: float = life
var xp_rate: float = 0.5 # Taux de chance de générer l'objet d'expérience
var xp_value: float = 10

@onready var _animated_sprite = $AnimatedSprite2D
var _animation_to_play: String
var _animated_sprite_id: int

@onready var navigation_agent: NavigationAgent2D = $EnemyNav
@onready var area2d: Area2D = $EnemyArea
var player = null

signal enemy_died  

func _ready():
	_animated_sprite_id = randi()%11+ 1
	_animation_to_play = "Run_" + str(_animated_sprite_id)
	navigation_agent.path_desired_distance = 100.0
	navigation_agent.target_desired_distance = 30.0
	call_deferred("actor_setup")

	area2d.monitoring = true
	area2d.connect("area_entered", Callable(self, "_on_Area2D_area_entered"))

	#player = get_node("/root/World/Player")
	player = get_tree().get_first_node_in_group("Player")
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
		var animation_to_play
		velocity = current_agent_position.direction_to(next_path_position) * movement_speed
		if velocity.x >0.0 : 
			_animated_sprite.flip_h = false
		else : 
			_animated_sprite.flip_h = true
		_animated_sprite.play(_animation_to_play)
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_Area2D_area_entered(area: Area2D):
	#print("Area entered:", area.name)
	#print("Groups of the entered area:")
	for group in area.get_groups():
		print(group)
	if area.is_in_group("Player"):
		#print("player")
		player = area.get_parent()  
		#print("Player node:", player)
		if player and player.has_method("take_damage"):
			#print("Player has take_damage method")
			player.take_damage(damage)

func _on_Player_died():
	print("Player died")
	player = null  

func take_damage(amount: float):
	current_life -= amount
	#print(current_life)
	if current_life <= 0:
		die() 
		
func die():
	emit_signal("enemy_died")
	AudioManager.play_enemy_death()
	if randi() % 100 < int(xp_rate * 100):
		call_deferred("spawn_experience_item")
	queue_free()  

func spawn_experience_item():
	var experience_scene = preload("res://scenes/experience_item.tscn")  
	var experience_instance = experience_scene.instantiate()
	experience_instance.global_position = global_position  
	experience_instance.set_xp_value(xp_value)
	get_parent().add_child(experience_instance)
