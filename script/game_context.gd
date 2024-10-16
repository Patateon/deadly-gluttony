extends Node

var time = 1 # en minutes
var number_of_kills = 0

@onready var world_timer = $WorldTimer

signal current_time(time_minute, time_seconde)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	world_timer.start(time * 60)
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	compute_time()
	
func compute_time():
	var time = int(world_timer.time_left)
	var secondes = time % 60
	var minutes = time / 60
	current_time.emit(minutes, secondes)
