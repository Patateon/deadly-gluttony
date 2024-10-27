extends RigidBody2D

@onready var _hurt_box = $HurtBox
@onready var _animated_sprite = $ProjectileSprite
@onready var stats = get_node("/root/World/Stats")

var damage 

var player
var index = 0
var npierce
var currentPierce=0
var weapon_stats: WeaponStats
var _lifetime_timer: Timer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	weapon_stats = load("res://ressources/weapons_stats.tres") as WeaponStats
	_animated_sprite.play()
	_hurt_box.body_entered.connect(_on_area_entered)
	player = get_tree().get_first_node_in_group("Player")
	if player:
		player.player_died.connect(_on_player_died)
	_animated_sprite.scale = player.area*_animated_sprite.scale * weapon_stats.area[index][weapon_stats.weapon_level[index]]
	_hurt_box.scale = player.area*_hurt_box.scale * weapon_stats.area[index][weapon_stats.weapon_level[index]]
	stats.fire_projectile_since_start += 1
	
	_lifetime_timer = Timer.new()
	_lifetime_timer.wait_time = 5.0
	_lifetime_timer.one_shot = true
	add_child(_lifetime_timer)
	_lifetime_timer.start()
	await get_tree().create_timer(5).timeout
	queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_area_entered(body):
	if body.is_in_group("NPC"):
		if body.has_method("take_damage") and player:
			body.take_damage((player.damage) * damage)
			currentPierce+=1
			if(currentPierce>=npierce) :
				queue_free()
			
func set_damage(new_damage):
	damage = new_damage
	
func get_index2() -> int:
	return index

func _on_player_died():
	player = null

func get_closest_enemy(enemies):
	var closest_enemy = null
	var closest_distance = INF
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	return closest_enemy
	
func fire_projectile(scene_root: Node,player_node : Node,position_: Vector2,weapon_attack_speed : float,player_attack_speed : float,weapon_damage : float,player_damage : float ,nproj : int , weapon_projectile_speed : float , player_projectile_speed,proj_pierce : int,up : int , right : int):
	var projectile_scene = load("res://scenes/weapon1.tscn") as PackedScene  # Chargement dynamique
	var enemies = scene_root.get_tree().get_nodes_in_group("NPC")
	damage=weapon_damage*player_damage
	if !enemies.is_empty():
		var projectile_instance = projectile_scene.instantiate() # première instance
		
		projectile_instance.set_damage(weapon_damage*player_damage)
		var enemy = get_closest_enemy(enemies)
		var traj = enemy.global_position - position_
		if traj.length() != 0:
			traj = traj.normalized()
		for n in range(nproj): # Si plusieurs projectiles on refait le tout avec une attente
			if n < nproj :
				await scene_root.get_tree().create_timer(0.1).timeout
			enemies = scene_root.get_tree().get_nodes_in_group("NPC") # On doit revoir la liste d'ennemis car avec le délai il peut ne plus y avoir d'ennemy ou celui selectionné au départ peut juste etre mort
			if enemy == null:
				traj = Vector2(1, 1)
			else:
				enemy = get_closest_enemy(enemies)
				traj = enemy.global_position - position_
			if traj.length() != 0:
				traj = traj.normalized()
			projectile_instance = projectile_scene.instantiate()
			if traj.x > 0:
				projectile_instance.get_node("ProjectileSprite").flip_h = true
			projectile_instance.set_damage(damage)
			projectile_instance.global_position = position_
			projectile_instance.apply_impulse( traj * player_projectile_speed * weapon_projectile_speed,Vector2.ZERO,)
			projectile_instance.npierce = proj_pierce
			player_node.add_child(projectile_instance)
			projectile_instance.global_position = position_
		
	
