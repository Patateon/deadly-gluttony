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
	
