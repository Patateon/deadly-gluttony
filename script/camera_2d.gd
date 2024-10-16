extends Camera2D

var distdeadzone = 50.0
var lerp_speed: float = 1.5
@onready var character = get_parent().get_node("Player")

func _ready() -> void:
	make_current()
	self.position = character.get_global_position()
	character.player_died.connect(_on_player_died)

	
func _process(_delta: float) -> void:
	if character:
		update_camera_position(_delta)
	
func update_camera_position(delta: float):
	if character:
		var current_dist = character.get_global_position().distance_to(get_screen_center_position())
		if current_dist > distdeadzone:
			var target_position = character.get_global_position()
			self.position = position.lerp(target_position, lerp_speed * delta)

func _on_player_died():
	character = null
