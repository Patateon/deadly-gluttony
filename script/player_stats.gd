extends  Resource
class_name PlayerStats

@export var damage_id = 0
@export var damage_label = "Damage"
@export var damage = []
@export var damage_level = 0

@export var attack_speed_id = 1
@export var attack_speed_label = "Attack Speed"
@export var attack_speed = []
@export var attack_speed_level = 0

@export var area_id = 2
@export var area_label = "Area of effect"
@export var area = []
@export var area_level = 0

@export var projectile_speed_id = 3
@export var projectile_speed_label = "Projectile speed"
@export var projectile_speed = []
@export var projectile_speed_level = 0

@export var life_id = 4
@export var life_label = "Life"
@export var life = []
@export var life_level = 0

@export var movespeed_id = 5
@export var movespeed_label = "Movement speed"
@export var movespeed = []
@export var movespeed_level = 0

func getStatsLevel(id: int):
	match id:
		damage_id:
			return damage_level
		attack_speed_id:
			return attack_speed_level
		area_id:
			return area_level
		projectile_speed_id:
			return projectile_speed_level
		life_id:
			return life_level
		movespeed_id:
			return movespeed_level
	
	return -1
	
func increaseStatsLevel(id: int):
	match id:
		damage_id:
			damage_level += 1
			return true
		attack_speed_id:
			attack_speed_level += 1
			return true
		area_id:
			area_level += 1
			return true
		projectile_speed_id:
			projectile_speed_level += 1
			return true
		life_id:
			life_level += 1
			return true
		movespeed_id:
			movespeed_level += 1
			return true
	
	return false
	

func getStats(id: int):
	match id:
		damage_id:
			return damage
		attack_speed_id:
			return attack_speed
		area_id:
			return area
		projectile_speed_id:
			return projectile_speed
		life_id:
			return life
		movespeed_id:
			return movespeed
	
	return -1
	
func getStatsName(id: int):
	match id:
		damage_id:
			return damage_label
		attack_speed_id:
			return attack_speed_label
		area_id:
			return area_label
		projectile_speed_id:
			return projectile_speed_label
		life_id:
			return life_label
		movespeed_id:
			return movespeed_label
	
	return -1
