extends CharacterBody2D
var speed = 300.0
var life = 100.0
var damage = 1
var atk_speed = 1
var movespeed = 1
var experience = 0
var level = 1
var weapons = []
var atk_speed_acc=[]

var current_life: float = life
var is_alive: bool = true  

signal player_died  

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
	var projectile_scene = preload("res://scenes/projectile.tscn") # arme initial proj burger
	weapons.append(projectile_scene)
	atk_speed_acc.append(0.0)
	set_health_bar()
	
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
				_animated_sprite.flip_h = true  # Facing right
			elif directionx < 0:
				_animated_sprite.flip_h = false   # Facing left
		else:
			velocity.x = move_toward(velocity.x, 0, speed * movespeed)
		
		# Vertical movement
		if directiony:
			velocity.y = directiony * speed * movespeed
		else:
			velocity.y = move_toward(velocity.y, 0, speed * movespeed)
		
	
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

func fire_projectile():
	var i = 0
	for projectile in weapons: 
		if atk_speed_acc[i] > atk_speed / weapon_stats.get_attack_speed(i):
			atk_speed_acc[i] = 0
			var enemies = get_tree().get_nodes_in_group("NPC")
			if !enemies.is_empty():
				var projectile_instance = projectile.instantiate()
				projectile_instance.set_index(i)
				projectile_instance.set_damage(weapon_stats.get_damage(i))
				projectile_instance.global_position = global_position
				var enemy = enemies.back()
				var traj = enemy.global_position - global_position
				projectile_instance.add_constant_central_force(traj * weapon_stats.get_projectile_speed(i))
				get_parent().add_child(projectile_instance)
		i += 1

func die():
	is_alive = false 
	emit_signal("player_died") 
	Utilities.switch_scene_end("end",self)
	
	queue_free()  
	
	
func _on_AttractionArea_body_entered(body):
	print("Detect body entered:", body.name)  
	if body.is_in_group("Item"):
		print("DetectG")
		body.set_target(self)

func gain_experience(amount):
	experience += amount
	print("Gained experience:", amount)
	print("Total experience:", experience)
