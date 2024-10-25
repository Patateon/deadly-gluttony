extends CharacterBody2D

var speed = 300.0
var life 
var damage 
var atk_speed 
var movespeed 
var projectile_speed
var area
var experience = 0
var Money = 0

var level = 1
var current_xp = 0
var max_xp = 100

var weapons = []
var atk_speed_acc=[]
var weapon_indices = {}#armes possibles pour le joueur
var weapon_stats: WeaponStats
var player_stats: PlayerStats

var up 
var right 

var current_life
var is_alive: bool = true  

signal money_gained(money)
signal player_died
signal xp_gained(current_xp, max_xp)
signal level_gained(level)
signal dollar_gained(dollars)

@onready var attraction_area: Area2D = $AttractionArea
@onready var _animated_sprite = $AnimatedSprite2D
@onready var stats = get_node("/root/World/Stats")


func _input(event):
	if event.is_action_pressed("fire"):
		fire_projectile()

func _ready():
	weapon_stats = load("res://ressources/weapons_stats.tres") as WeaponStats
	player_stats = load("res://ressources/player_stats.tres") as PlayerStats
	life = player_stats.life[player_stats.life_level]
	current_life=life
	damage = player_stats.damage[player_stats.damage_level]
	atk_speed = player_stats.attack_speed[player_stats.attack_speed_level]
	area = player_stats.area[player_stats.area_level]
	projectile_speed =  player_stats.projectile_speed[player_stats.projectile_speed_level]
	movespeed = player_stats.movespeed[player_stats.movespeed_level]
	attraction_area.body_entered.connect(_on_AttractionArea_body_entered)
	$HealthBar.max_value = 100
	#preload toutes les scenes d'armes et les append a weapons quand il l'obtient, penser compteur attack speed en append un
	var projectile_scene = preload("res://scenes/weapon1.tscn") # arme initial proj burger , indice 0
	var projectile_scene2 = preload("res://scenes/weapon2.tscn") # indice 1 , etc
	weapon_indices[projectile_scene] = 0
	weapon_indices[projectile_scene2] = 1
	weapons.append(projectile_scene)#ajout de l'arme initiale
	#weapons.append(projectile_scene2)#append pour rajouter l'arme au joueur
	atk_speed_acc.append(0.0)
	#atk_speed_acc.append(0.0)
	set_health_bar()
	level_gained.emit(level)
	xp_gained.emit(current_xp, max_xp)
	
	
func _process(delta: float) -> void:
	set_health_bar()

	for i in range(atk_speed_acc.size()):  
		atk_speed_acc[i] += delta 
	fire_projectile()

func _physics_process(delta: float) -> void:
	if is_alive:  
		var directionx := Input.get_axis("Left", "Right")
		var directiony := Input.get_axis("Up", "Down")
		# Horizontal movement
		if directionx:
			velocity.x = directionx * speed * movespeed
			# Flip the sprite based on direction
			if directionx > 0:
				right=1
				_animated_sprite.flip_h = false  # Facing right
			elif directionx < 0:
				right=-1
				_animated_sprite.flip_h = true   # Facing left
			else : 
				right=0
		else:
			velocity.x = move_toward(velocity.x, 0, speed * movespeed)
		
		# Vertical movement
		velocity.y = directiony * speed * movespeed
		if directiony > 0:
			up = 1
		elif directiony < 0:
			up = -1
		else:
			up = 0
		
	
		move_and_slide()
		if directionx != 0 or directiony != 0:
			_animated_sprite.play("Run")
		elif velocity.length() == 0.0:
			_animated_sprite.play("Idle")

func kill_all_enemies():
	var enemies = get_tree().get_nodes_in_group("NPC")
	for enemy in enemies:
		if enemy.has_method("die"):
			enemy.die()
			
func take_damage(amount: float):
	AudioManager.play_player_hit()
	current_life -= amount
	print(current_life)
	if current_life <= 0:
		die()
		
func set_health_bar() -> void:
	$HealthBar.value = current_life


func deg2rad(degrees):
	return degrees * PI / 180.0
	
func get_closest_enemy(enemies):
	var closest_enemy = null
	var closest_distance = INF
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_enemy = enemy
	
	return closest_enemy
	
func fire_projectile():
	var i = 0
	for projectile in weapons: # tableau armes
		if atk_speed_acc[i] > atk_speed / weapon_stats.attack_speed[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]]: # compteur temps pour vitesse d'attaque
			atk_speed_acc[i] = 0
			var enemies = get_tree().get_nodes_in_group("NPC")
			if !enemies.is_empty():
				var projectile_instance = projectile.instantiate() # première instance
				projectile_instance.set_damage(weapon_stats.damage[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]])
				projectile_instance.global_position = global_position
				var enemy = get_closest_enemy(enemies)
				var traj = enemy.global_position - global_position
				if traj.length() != 0:
					traj = traj.normalized()
				if weapon_indices[projectile] == 0:
					for n in range(weapon_stats.number_proj[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]]): # Si plusieurs projectiles on refait le tout avec une attente
						if n < weapon_stats.number_proj[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]] :
							await get_tree().create_timer(0.1).timeout
						enemies = get_tree().get_nodes_in_group("NPC") # On doit revoir la liste d'ennemis car avec le délai il peut ne plus y avoir d'ennemy ou celui selectionné au départ peut juste etre mort
						if enemy == null:
							traj = Vector2(1, 1)
						else:
							enemy = get_closest_enemy(enemies)
							traj = enemy.global_position - global_position
						if traj.length() != 0:
							traj = traj.normalized()
						projectile_instance = projectile.instantiate()
						if traj.x > 0:
							projectile_instance.get_node("ProjectileSprite").flip_h = true
						projectile_instance.set_damage(weapon_stats.damage[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]])
						projectile_instance.global_position = global_position
						projectile_instance.apply_impulse( traj * projectile_speed * weapon_stats.projectile_speed[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]],Vector2.ZERO,)
						projectile_instance.npierce = weapon_stats.proj_pierce[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]]
						get_parent().add_child(projectile_instance)
						
				if weapon_indices[projectile] == 1:
					var nproj = weapon_stats.number_proj[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]]
					# selon nb proj faire angle de trajectoire
					if right == 1:
						traj.x = 1
					elif right == -1:
						traj.x = -1
					else:
						traj.x = 0
					if up == 1:
						traj.y = 1
					elif up == -1:
						traj.y = -1
					else:
						traj.y = 0
					if traj.length() != 0:
						traj = traj.normalized()
					if nproj == 1:
						# Pour un seul projectile, on utilise la trajectoire de base
						projectile_instance = projectile.instantiate()
						projectile_instance.set_damage(damage * weapon_stats.damage[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]])
						projectile_instance.global_position = global_position
						projectile_instance.apply_impulse( traj * projectile_speed * weapon_stats.projectile_speed[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]],Vector2.ZERO)
						projectile_instance.npierce = weapon_stats.proj_pierce[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]]
						get_parent().add_child(projectile_instance)
					else:
						var angle_step = 45.0 / nproj
						if nproj % 2 == 1:
							projectile_instance = projectile.instantiate()
							projectile_instance.set_damage(damage * weapon_stats.damage[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]])
							projectile_instance.global_position = global_position
							projectile_instance.apply_impulse( traj * projectile_speed * weapon_stats.projectile_speed[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]],Vector2.ZERO)
							projectile_instance.npierce = weapon_stats.proj_pierce[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]]
							get_parent().add_child(projectile_instance)
						for n in range(nproj / 2):
							var angle = (n + 1) * angle_step
							var rad = deg2rad(angle)
							var traj_x1 = traj.x * cos(rad) - traj.y * sin(rad)
							var traj_y1 = traj.x * sin(rad) + traj.y * cos(rad)
							var traj_x2 = traj.x * cos(-rad) - traj.y * sin(-rad)
							var traj_y2 = traj.x * sin(-rad) + traj.y * cos(-rad)
							var new_traj1 = Vector2(traj_x1, traj_y1).normalized()
							var new_traj2 = Vector2(traj_x2, traj_y2).normalized()
							projectile_instance = projectile.instantiate()
							projectile_instance.set_damage(damage * weapon_stats.damage[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]])
							projectile_instance.global_position = global_position
							projectile_instance.apply_impulse( new_traj1 * projectile_speed * weapon_stats.projectile_speed[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]],Vector2.ZERO,)
							projectile_instance.npierce = weapon_stats.proj_pierce[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]]
							get_parent().add_child(projectile_instance)
							projectile_instance = projectile.instantiate()
							projectile_instance.set_damage(damage * weapon_stats.damage[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]])
							projectile_instance.global_position = global_position
							projectile_instance.apply_impulse( new_traj2 * projectile_speed * weapon_stats.projectile_speed[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]],Vector2.ZERO)
							projectile_instance.npierce = weapon_stats.proj_pierce[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]]
							get_parent().add_child(projectile_instance)
		i += 1


func level_up():
	AudioManager.play_player_lvl()
	level += 1
	max_xp *= 1.25
	level_gained.emit(level)
	
func update_player_stat():
	life = player_stats.life[player_stats.life_level]
	damage = player_stats.damage[player_stats.damage_level]
	atk_speed = player_stats.attack_speed[player_stats.attack_speed_level]
	area = player_stats.area[player_stats.area_level]
	projectile_speed =  player_stats.projectile_speed[player_stats.projectile_speed_level]
	movespeed = player_stats.movespeed[player_stats.movespeed_level]
	

func die():
	AudioManager.stop_music()
	AudioManager.play_player_death()
	is_alive = false 
	emit_signal("player_died") 
	queue_free()  

	
	
func _on_AttractionArea_body_entered(body):
	#print("Detect body entered:", body.name)  
	if body.is_in_group("Item"):
		#print("DetectG")
		body.set_target(self)

func gain_experience(amount):
	money_gained.emit(amount)
	current_xp += amount
	if (current_xp >= max_xp):
		current_xp -= max_xp
		level_up()
	xp_gained.emit(current_xp, max_xp)
	dollar_gained.emit(amount)
	#print("Gained experience:", amount)
	#print("Total experience:", experience)
