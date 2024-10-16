extends Node
var rand =  RandomNumberGenerator.new()
var is_paused = false
var pause_position = 0.0  # Pour stocker la position actuelle du son
@onready var musicplayer: AudioStreamPlayer = $Music1
var sound_player_e
var sound_player_p
var music = 0
var nbrenemysounds = 2
 


func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("Pause"):
		if is_paused:
			# Reprendre la lecture à la position où elle a été arrêtée
			play_music(pause_position)
			is_paused = false
		else:
			# Mettre en pause en sauvegardant la position actuelle
			pause_position = musicplayer.get_playback_position()
			stop_music()
			is_paused = true
				
	
	
		
func _ready():
	pass
	
func play_music(pause_position):
	musicplayer.play(pause_position)
	
func stop_music():
	musicplayer.stop()
	
func selectmusic(music : int):
	if music == 0:
		musicplayer = $Music1
	else :
		musicplayer = $Music2
	pause_position = 0.0
	play_music(pause_position)
	
func play_enemy_death():
	var nbr = rand.randi_range(0 , nbrenemysounds-1)
	if nbr == 0:
		sound_player_e = $Enemy_death1
		sound_player_e.play()
	if nbr == 1:
		sound_player_e= $Enemy_death2
		sound_player_e.play()
	if nbr == 2:
		sound_player_e = $Enemy_death3
		sound_player_e.play()
		
func play_exp_pickup():
	pass
func play_player_death():
	sound_player_p = $Player_death
	sound_player_p.play()
func play_player_hit():
	sound_player_p = $player_hit
	sound_player_p.play()


		
	
