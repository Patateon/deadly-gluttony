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
var max_xp = 20

var weapons = []
var atk_speed_acc=[]
var weapon_indices = {}#armes possibles pour le joueur
var weapon_stats: WeaponStats
var player_stats: PlayerStats

var up = 1
var right = 1

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
	
	# Preload chaque armes disponibles
	preloadWeapons()
	# Attribut l'arme 0 (burger) au joueur
	addWeapons(0)
	# Initialise la barre de vie du joueur
	$HealthBar.max_value = 100
	set_health_bar()
	# Initialise le niveau du joueur à 1
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
		if directionx != 0:
			velocity.x = directionx * speed * movespeed
			if directionx > 0:
				right = 1
				_animated_sprite.flip_h = false  
			elif directionx < 0:
				right = -1
				_animated_sprite.flip_h = true   
		else:
			right = 0
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
	if current_life <= 0:
		die()
		
func set_health_bar() -> void:
	$HealthBar.value = current_life

func deg2rad(degrees):
	return degrees * PI / 180.0
	
	
func preloadWeapons():
	#preload toutes les scenes d'armes et les append a weapons quand il l'obtient, penser compteur attack speed en append un
	var projectile_scene = preload("res://scenes/weapon1.tscn") # arme initial proj burger , indice 0
	var projectile_scene2 = preload("res://scenes/weapon2.tscn") # indice 1 , etc
	weapon_indices[projectile_scene] = 0
	weapon_indices[projectile_scene2] = 1
	

func addWeapons(id: int):
	for proj in weapon_indices:
		var indices = weapon_indices[proj]
		if (indices == id):
			weapons.append(proj)
			atk_speed_acc.append(0.0)
			weapon_stats.weapon_level[id] = 0

func getWeapons(id: int):
	for proj in weapon_indices:
		if (weapon_indices[proj] == id):
			return proj

	
func fire_projectile():
	var i = 0
	for projectile in weapons: # tableau armes
		if atk_speed_acc[i] > atk_speed / weapon_stats.attack_speed[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]]: # compteur temps pour vitesse d'attaque
			atk_speed_acc[i] = 0
			var projectile_instance = projectile.instantiate()
			projectile_instance.fire_projectile(get_node("/root/World"),global_position,
			weapon_stats.attack_speed[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]],
			player_stats.attack_speed[player_stats.attack_speed_level],
			weapon_stats.damage[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]],
			player_stats.damage[player_stats.damage_level],
			weapon_stats.number_proj[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]],
			weapon_stats.projectile_speed[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]],
			player_stats.projectile_speed[player_stats.projectile_speed_level],
			weapon_stats.proj_pierce[weapon_indices[projectile]][weapon_stats.weapon_level[weapon_indices[projectile]]],
			up,right)
		i += 1


func level_up():
	AudioManager.play_player_lvl()
	level += 1
	max_xp *= 1.25
	level_gained.emit(level)
	
func update_player_stat():
	# Increase current life if max life is increase
	var diff_life = player_stats.life[player_stats.life_level] - life
	current_life += diff_life
	
	# Update each stats
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
	if body.is_in_group("Item"):
		body.set_target(self)

func gain_experience(amount):
	money_gained.emit(amount)
	current_xp += amount
	if (current_xp >= max_xp):
		current_xp -= max_xp
		level_up()
	xp_gained.emit(current_xp, max_xp)
	dollar_gained.emit(amount)
