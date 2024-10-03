extends RigidBody2D

@onready var _hurt_box = $HurtBox
@onready var _animated_sprite = $AnimatedSprite2D
@onready var weapon_stats = get_node("/root/World/WeaponStats")
var damage 
var player
var index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_animated_sprite.play()
	_hurt_box.connect("body_entered", Callable(_on_area_entered))
	player = get_tree().get_first_node_in_group("Player")
	_animated_sprite.scale = _animated_sprite.scale * weapon_stats.get_area(index)
	_hurt_box.scale = _hurt_box.scale*weapon_stats.get_area(index)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void :
	pass
	
func _on_area_entered(body):
	if body.is_in_group("NPC"):
		if body.has_method("take_damage"):
			body.take_damage((player.damage)*damage)
			
func set_damage(new_damage) : 
	damage = new_damage
	
func set_index(new_index):
	index=new_index
	

	
			
