# WeaponStats.gd
extends Node


var damage: Array = [5.0, 15.0, 1.0]          
var attack_speed: Array = [1.0, 1.0, 1.0]       
var area: Array = [5.0, 1.0, 1.0]                
var projectile_speed: Array = [1.0, 1.0, 1.0]  


func update_stats(index: int, new_damage: float, new_attack_speed: float, new_area: float, new_projectile_speed: float):
	if index >= 0 and index < damage.size():
		damage[index] = new_damage
		attack_speed[index] = new_attack_speed
		area[index] = new_area
		projectile_speed[index] = new_projectile_speed
	else:
		print("Index out of bounds!")


func get_damage(index: int) -> float:
	if index >= 0 and index < damage.size():
		return damage[index]
	print("Index out of bounds!")
	return 0.0  

func get_attack_speed(index: int) -> float:
	if index >= 0 and index < attack_speed.size():
		return attack_speed[index]
	print("Index out of bounds!")
	return 0.0  

func get_area(index: int) -> float:
	if index >= 0 and index < area.size():
		return area[index]
	print("Index out of bounds!")
	return 0.0 

func get_projectile_speed(index: int) -> float:
	if index >= 0 and index < projectile_speed.size():
		return projectile_speed[index]
	print("Index out of bounds!")
	return 0.0 


func set_damage(index: int, new_damage: float) -> void:
	if index >= 0 and index < damage.size():
		damage[index] = new_damage
	else:
		print("Index out of bounds!")

func set_attack_speed(index: int, new_attack_speed: float) -> void:
	if index >= 0 and index < attack_speed.size():
		attack_speed[index] = new_attack_speed
	else:
		print("Index out of bounds!")

func set_area(index: int, new_area: float) -> void:
	if index >= 0 and index < area.size():
		area[index] = new_area
	else:
		print("Index out of bounds!")

func set_projectile_speed(index: int, new_projectile_speed: float) -> void:
	if index >= 0 and index < projectile_speed.size():
		projectile_speed[index] = new_projectile_speed
	else:
		print("Index out of bounds!")

# Méthode pour imprimer les statistiques
func print_stats():
	for i in range(damage.size()):
		print("Weapon ", i + 1, ": Damage: ", damage[i], ", Attack Speed: ", attack_speed[i], 
			  ", Area: ", area[i], ", Projectile Speed: ", projectile_speed[i])
