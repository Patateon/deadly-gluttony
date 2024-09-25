extends RigidBody2D

@onready var _animated_sprite = $AnimatedSprite2D

var projectile_type = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animated_sprite.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
