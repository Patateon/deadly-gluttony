extends Node

static var fire_projectile_since_start=0
static var experience


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_fire_projectile_since_start():
	return fire_projectile_since_start


func get_experience():
	return experience
