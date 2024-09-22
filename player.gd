extends CharacterBody2D

var speed = 300.0
var life = 100.0
var damage = 1
var atk_speed = 1
var movespeed = 1
var experience = 0
var level = 1

var current_life: float = life
var is_alive: bool = true  

signal player_died  

func _physics_process(delta: float) -> void:
	if is_alive:  
		var directionx := Input.get_axis("ui_left", "ui_right")
		var directiony := Input.get_axis("ui_up", "ui_down")
		if directionx:
			velocity.x = directionx * speed * movespeed
		else:
			velocity.x = move_toward(velocity.x, 0, speed * movespeed)
		if directiony:
			velocity.y = directiony * speed * movespeed
		else:
			velocity.y = move_toward(velocity.y, 0, speed * movespeed)
	
		move_and_slide()

func take_damage(amount: float):
	current_life -= amount
	print(current_life)
	if current_life <= 0:
		die() 

func die():
	is_alive = false 
	emit_signal("player_died") 
	queue_free()  
