extends RigidBody2D

@onready var _hurt_box = $HurtBox
@onready var _animated_sprite = $ProjectileSprite
@onready var stats = get_node("/root/World/Stats")

var damage 
var player
var index = 1
var npierce
var currentPierce=0
var weapon_stats: WeaponStats
var _lifetime_timer: Timer
var attack_timer=0

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
	
func get_index2() -> int :
	return index

func _on_player_died():
	player = null
	
func deg2rad(degrees):
	return degrees * PI / 180.0
	
func fire_projectile(scene_root: Node, position_: Vector2, weapon_attack_speed: float, player_attack_speed: float, weapon_damage: float, player_damage: float, nproj: int, weapon_projectile_speed: float, player_projectile_speed: float, proj_pierce: int, up: int, right: int):
	var traj = Vector2(right, up).normalized() * -1  
	var projectile_scene = load("res://scenes/weapon2.tscn") as PackedScene
	damage = weapon_damage * player_damage
	if nproj == 1:
		var projectile_instance = projectile_scene.instantiate()
		projectile_instance.global_position = position_
		projectile_instance.set_damage(damage)
		projectile_instance.npierce = proj_pierce
		projectile_instance.apply_impulse(traj * player_projectile_speed * weapon_projectile_speed, Vector2.ZERO)
		scene_root.add_child(projectile_instance)  # Ajouter au niveau de la scène racine, pas du joueur

	else:
		var angle_step = 45.0 / nproj
		if nproj % 2 == 1:
			var projectile_instance = projectile_scene.instantiate()
			projectile_instance.global_position = position_
			projectile_instance.set_damage(damage)
			projectile_instance.npierce = proj_pierce
			projectile_instance.apply_impulse(traj * player_projectile_speed * weapon_projectile_speed, Vector2.ZERO)
			scene_root.add_child(projectile_instance)

		for n in range(nproj / 2):
			var angle = (n + 1) * angle_step
			var rad = deg2rad(angle)

			
			var traj_left = Vector2(
				traj.x * cos(rad) - traj.y * sin(rad),
				traj.x * sin(rad) + traj.y * cos(rad)
			).normalized()
			var traj_right = Vector2(
				traj.x * cos(-rad) - traj.y * sin(-rad),
				traj.x * sin(-rad) + traj.y * cos(-rad)
			).normalized()

			for new_traj in [traj_left, traj_right]:
				var projectile_instance = projectile_scene.instantiate()
				projectile_instance.global_position = position_
				projectile_instance.set_damage(damage)
				projectile_instance.npierce = proj_pierce
				projectile_instance.apply_impulse(new_traj * player_projectile_speed * weapon_projectile_speed, Vector2.ZERO)
				scene_root.add_child(projectile_instance)

	
