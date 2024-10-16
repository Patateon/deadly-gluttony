extends CharacterBody2D
var speed = 300.0
var life = 1.0
var damage = 1
var atk_speed = 1
var movespeed = 1
var experience = 0
var level = 1
var weapons = []
var atk_speed_acc=[]

var projectile_speed=10
var up 
var right 


var current_xp = 0
var max_xp = 100
var current_life: float = life
var is_alive: bool = true  

signal player_died
signal xp_gained(current_xp, max_xp)
signal level_gained(level)
signal dollar_gained(dollars)

@onready var attraction_area: Area2D = $AttractionArea

@onready var _animated_sprite = $AnimatedSprite2D

@onready var weapon_stats = get_node("/root/World/WeaponStats") # stat armes a mettre a jour lors level up
@onready var stats = get_node("/root/World/Stats")


func _input(event):
	if event.is_action_pressed("fire"):
		fire_projectile()

func _ready():
	attraction_area.body_entered.connect(_on_AttractionArea_body_entered)
	$HealthBar.max_value = 100
	var projectile_scene = preload("res://scenes/weapon1.tscn") # arme initial proj burger
	var projectile_scene2 = preload("res://scenes/weapon2.tscn") 
	weapons.append(projectile_scene)
	weapons.append(projectile_scene2)
	atk_speed_acc.append(0.0)
	atk_speed_acc.append(0.0)
	set_health_bar()
	level_gained.emit(level)
	xp_gained.emit(current_xp, max_xp)
	
	
func _process(delta: float) -> void:
	set_health_bar()
	stats.experience = experience

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
				_animated_sprite.flip_h = true  # Facing right
			elif directionx < 0:
				right=-1
				_animated_sprite.flip_h = false   # Facing left
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
	weapon_stats.set_attack_speed(0, 3)
			
func take_damage(amount: float):
	current_life -= amount
	print(current_life)
	if current_life <= 0:
		die()
		
func set_health_bar() -> void:
	$HealthBar.value = current_life

func deg2rad(degrees):
	return degrees * PI / 180.0
	
func fire_projectile():
	var i = 0
	for projectile in weapons: #tableau armes
		if atk_speed_acc[i] > atk_speed / weapon_stats.get_attack_speed(i):#coompteur temps pour vitesse d'attaque
			atk_speed_acc[i] = 0
			var enemies = get_tree().get_nodes_in_group("NPC")
			if !enemies.is_empty():
				var projectile_instance = projectile.instantiate()#première instance
				var index = projectile_instance.get_index2()
				projectile_instance.set_damage(weapon_stats.get_damage(index))
				projectile_instance.global_position = global_position
				var enemy = enemies.back()
				var traj = enemy.global_position - global_position
				if traj.length() != 0:
					traj = traj.normalized()
				if traj.x > 0 :
					projectile_instance.get_node("ProjectileSprite").flip_h = true
				if index == 0:
					for n in range(weapon_stats.get_nproj(index)):#Si plusieurs projectiles on refait le tout avec une attente
						if n < weapon_stats.get_nproj(index) :
							await get_tree().create_timer(0.1).timeout
						enemies = get_tree().get_nodes_in_group("NPC")#On doit revoir la liste d'ennemis car avec le délai il peut ne plus y avoir d'ennemy ou celui selectionné au départ peut juste etre mort
						enemy = enemies.back()
						if(enemy==null) :
							traj = Vector2(1,1)
						else : 
							traj = enemy.global_position - global_position
						if traj.length() != 0:
							traj = traj.normalized()
						if traj.x > 0 :
							projectile_instance.get_node("ProjectileSprite").flip_h = true
						projectile_instance = projectile.instantiate()
						projectile_instance.set_damage(weapon_stats.get_damage(index))
						projectile_instance.global_position = global_position
						projectile_instance.add_constant_central_force(traj * projectile_speed * weapon_stats.get_projectile_speed(index))
						get_parent().add_child(projectile_instance)

						
				if(index == 1) :
					var nproj = weapon_stats.get_nproj(index)
					#selon nb proj faire angle de trajectoire  
					if (right==1) :
						traj.x=1
					elif(right==-1) : 
						traj.x=-1
					else :
						traj.x=0
					if(up==1) :
						traj.y=1
					elif(up==-1) : 
						traj.y =-1
					else :
						traj.y=0
					if traj.length() != 0:
						traj = traj.normalized()
					if nproj == 1 :
					# Pour un seul projectile, on utilise la trajectoire de base
						projectile_instance = projectile.instantiate()
						projectile_instance.set_damage(weapon_stats.get_damage(index))
						projectile_instance.global_position = global_position
						projectile_instance.add_constant_central_force(traj * projectile_speed * weapon_stats.get_projectile_speed(index))
						get_parent().add_child(projectile_instance)
					else:
						var angle_step = 45.0 / nproj 
						if(nproj%2==1) : 
							projectile_instance = projectile.instantiate()
							projectile_instance.set_damage(weapon_stats.get_damage(index))
							projectile_instance.global_position = global_position
							projectile_instance.add_constant_central_force(traj * projectile_speed * weapon_stats.get_projectile_speed(index))
							get_parent().add_child(projectile_instance)
						for n in range(nproj/2):
							var angle = (n+1) * angle_step
							var rad = deg2rad(angle)
							var traj_x1 = traj.x * cos(rad) - traj.y * sin(rad)
							var traj_y1 = traj.x * sin(rad) + traj.y * cos(rad)
							var traj_x2 = traj.x * cos(-rad) - traj.y * sin(-rad)
							var traj_y2 = traj.x * sin(-rad) + traj.y * cos(-rad)
							var new_traj1 = Vector2(traj_x1, traj_y1).normalized()
							var new_traj2 = Vector2(traj_x2, traj_y2).normalized()
							projectile_instance = projectile.instantiate()
							projectile_instance.set_damage(weapon_stats.get_damage(index))
							projectile_instance.global_position = global_position
							projectile_instance.add_constant_central_force(new_traj1 * projectile_speed * weapon_stats.get_projectile_speed(index))
							get_parent().add_child(projectile_instance)
							projectile_instance = projectile.instantiate()
							projectile_instance.set_damage(weapon_stats.get_damage(index))
							projectile_instance.global_position = global_position
							projectile_instance.add_constant_central_force(new_traj2 * projectile_speed * weapon_stats.get_projectile_speed(index))
							get_parent().add_child(projectile_instance)					
		i += 1

func level_up():
	level += 1
	max_xp *= 1.25
	level_gained.emit(level)

func die():
	is_alive = false 
	emit_signal("player_died") 
	var UI = get_parent().get_node("UI")
	UI.get_node("Pause_Menu").hide()
	var GameOver= preload("res://scenes/end.tscn").instantiate()
	UI.add_child(GameOver)
	#queue_free()  

	
	
func _on_AttractionArea_body_entered(body):
	#print("Detect body entered:", body.name)  
	if body.is_in_group("Item"):
		print("DetectG")
		body.set_target(self)

func gain_experience(amount):

	current_xp += amount
	if (current_xp >= max_xp):
		current_xp -= max_xp
		level_up()
	xp_gained.emit(current_xp, max_xp)
	dollar_gained.emit(amount)
	print("Gained experience:", amount)
	print("Total experience:", experience)
