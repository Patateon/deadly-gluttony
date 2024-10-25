extends Node

var time = 3 # en minutes
var totalTime = 0 # en secondes
var number_of_kills = 0

@onready var world_timer = $WorldTimer

signal current_time(time_minute, time_seconde)

func _ready() -> void:
	totalTime = time * 60 
	world_timer.start(totalTime)
	pass
	
func _process(delta: float) -> void:
	compute_time()

func compute_time():
	var time_left = int(world_timer.time_left)
	var secondes = time_left % 60
	var minutes = time_left / 60
	current_time.emit(minutes, secondes)
