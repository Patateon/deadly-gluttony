extends Camera2D

var distdeadzone = 50.
var lerp_speed: float = 1.5
@onready var character = get_node("/root/World/Player")

func _ready() -> void:
	make_current()
	self.position = character.get_global_position()
	
func _process(_delta: float) -> void:
	pass
	#update_camera_position(_delta)
	
	
func update_camera_position(delta: float):
	var current_dist = character.get_global_position().distance_to(get_screen_center_position())
	#self.position = character.get_global_position()
	if current_dist > distdeadzone:
		var target_position = character.get_global_position()
		#self.position = target_position
		self.position = position.lerp(target_position, lerp_speed*delta)
