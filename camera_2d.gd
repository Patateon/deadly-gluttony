extends Camera2D

var distdeadzone = 100.
# Référence au CharacterBody2D (par exemple, le joueur)
  # Assurez-vous que le chemin vers le personnage est correct
@onready var character = get_node("/root/Node2D/CharacterBody2D")

func _ready() -> void:
	make_current()
	
func _process(_delta: float) -> void:
	update_camera_position()
	
func update_camera_position():
	var current_dist = character.get_global_position().distance_to( get_screen_center_position())
	if (current_dist > distdeadzone):
		self.position = character.get_global_position()
