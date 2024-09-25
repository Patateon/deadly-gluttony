extends RigidBody2D

@onready var _hurt_box = $HurtBox
@onready var _animated_sprite = $AnimatedSprite2D

var projectile_type = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animated_sprite.play()
	_hurt_box.connect("body_entered", Callable(_on_area_entered))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_area_entered(body):
	pass
