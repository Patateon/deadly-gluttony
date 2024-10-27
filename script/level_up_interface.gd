extends Control

@onready var player = get_node("/root/World/Player")
var statNumber = 6
var options_availables = []

signal choice_1(option_chosen)
signal choice_2(option_chosen)
signal choice_3(option_chosen)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_choix_1_pressed() -> void:
	choice_1.emit(options_availables[0])


func _on_choix_2_pressed() -> void:
	choice_2.emit(options_availables[1])


func _on_choix_3_pressed() -> void:
	choice_3.emit(options_availables[2])


func _on_world_level_options(options: Variant) -> void:
	var player_stats = player.player_stats
	var weapons_stats = player.weapon_stats
	options_availables = options
	
	var buttons = [
		$Level_UP_menu/Content/Choix1,
		$Level_UP_menu/Content/Choix2,
		$Level_UP_menu/Content/Choix3
	]
	
	for i in range(len(options)):
		
		# Check if the current option is a weapon or a stat
		if (options[i] < statNumber):
			var label = player_stats.getStatsName(options[i])
			var amount = player_stats.getStats(options[i])[player_stats.getStatsLevel(options[i])+1]
			buttons[i].text = "Increase {} to {}".format([label.to_lower(), str(amount)], "{}")
		else:
			var weapon_id = options[i] - statNumber
			var label = weapons_stats.weapon_names[weapon_id]
			
			buttons[i].text = "Increase {} level by 1".format([label.to_lower()], "{}")
