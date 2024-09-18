extends CharacterBody2D

var movement_speed: float = 200.0
var attack_distance: float = 1.0
var damage: float = 10.0  # Définissez les dégâts que l'ennemi inflige
var movement_target_position: Vector2

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var area2d: Area2D = $Area2D  # Assurez-vous que le nœud Area2D est correctement nommé

func _ready():
	navigation_agent.path_desired_distance = 100.0
	navigation_agent.target_desired_distance = 30.0
	call_deferred("actor_setup")

	# Configurer la détection des collisions pour l'Area2D
	area2d.monitoring = true
	area2d.connect("area_entered", Callable(self, "_on_Area2D_area_entered"))

func actor_setup():
	await get_tree().physics_frame
	update_movement_target()

func update_movement_target():
	var player = get_node("/root/World/Player")
	if player:
		movement_target_position = player.global_position
		set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _physics_process(delta: float) -> void:
	var player = get_node("/root/World/Player")
	if not player:
		return

	var distance_to_player = global_position.distance_to(player.global_position)

	if distance_to_player > attack_distance:
		update_movement_target()

		if navigation_agent.is_navigation_finished():
			print("Navigation finished. Recalculating target.")
			return

		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()

		velocity = current_agent_position.direction_to(next_path_position) * movement_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		# Vous pouvez ajouter d'autres comportements ici si nécessaire

func _on_Area2D_area_entered(area: Area2D):
	if area.is_in_group("Player"):
		var player = area.get_parent()  # Ou utilisez une autre méthode pour obtenir la référence du joueur
		if player and player.has_method("take_damage"):
			player.take_damage(damage)
