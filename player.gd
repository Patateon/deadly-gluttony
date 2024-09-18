extends CharacterBody2D


const SPEED = 300.0
const LIFE = 100.0
const DAMAGE = 1
const ATTSPEED = 1
const MOVESPEED = 1




func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionx := Input.get_axis("ui_left", "ui_right")
	var directiony := Input.get_axis("ui_up", "ui_down")
	if directionx:
		velocity.x = directionx * SPEED * MOVESPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED*MOVESPEED)
	if directiony:
		velocity.y = directiony * SPEED * MOVESPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED*MOVESPEED)
	
	move_and_slide()
	

		
