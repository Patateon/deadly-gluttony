extends CharacterBody2D

const SPEED = 300.0
const LIFE = 100.0
const DAMAGE = 1
const ATTSPEED = 1
const MOVESPEED = 1
const EXPERIENCE = 0
const LEVEL = 1

var current_life: float = LIFE

func _physics_process(delta: float) -> void:
	var directionx := Input.get_axis("ui_left", "ui_right")
	var directiony := Input.get_axis("ui_up", "ui_down")
	if directionx:
		velocity.x = directionx * SPEED * MOVESPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * MOVESPEED)
	if directiony:
		velocity.y = directiony * SPEED * MOVESPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED * MOVESPEED)
	
	move_and_slide()

func take_damage(amount: float):
	current_life -= amount
	if current_life <= 0:
		die()  # Assurez-vous que la méthode die() est définie pour gérer la mort du joueur

func die():
	queue_free()  # Vous pouvez remplacer cette ligne par la gestion de la mort du joueur
