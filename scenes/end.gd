extends Control

@onready var stats = get_node("/root/World/Stats")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Projejectile/Projectil_value.text=str(stats.get_fire_projectile_since_start())
	$VBoxContainer/Money/Money_value.text=str(stats.get_experience())
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	var current_scene = get_tree().current_scene  # Get the current scene
	get_tree().reload_current_scene()  # Reload it from scratch
	queue_free()
