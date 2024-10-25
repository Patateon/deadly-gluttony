extends Node

var fire_projectile_since_start=0
var Money_gain=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_fire_projectile_since_start():
	return fire_projectile_since_start


func get_money():
	return Money_gain


func _on_player_money_gained(money: Variant) -> void:
	Money_gain = Money_gain + money
