extends Node2D

var xp_value = 0
var target = null
var attraction_speed = 100.0

func set_xp_value(value):
	xp_value = value

func set_target(new_target):
	target = new_target

func _ready() -> void:
	add_to_group("Item")  # Ajouter l'instance au groupe "Item"
	print("XP Value:", xp_value)

func _process(delta: float) -> void:
	if target and is_instance_valid(target):  
		if is_instance_valid(self):  
			var direction = global_position.direction_to(target.global_position)
			global_position += direction * attraction_speed * delta

			if global_position.distance_to(target.global_position) < 100.0:
				target.gain_experience(xp_value)
				queue_free()
