extends CanvasLayer

var current_dollars = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TOP/XP/Level_Label.text = "[b]LVL : 1 [/b]"
	$TOP/MainHud/Stats/Kills/Kills_Label.text = " : 0"
	$TOP/MainHud/Stats/Money/Money_Label.text = " : 0"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_level_gained(level: Variant) -> void:
	$TOP/XP/Level_Label.text = "[b]LVL : " + str(level) + "[/b]"


func _on_player_xp_gained(current_xp: Variant, max_xp: Variant) -> void:
	$TOP/XP/XP_BAR/XP_Numbers.text = "[center][b]" + str(int(current_xp))\
								  + "/" + str(int(max_xp)) + "[/b][/center]"
	$TOP/XP/XP_BAR.max_value = max_xp
	$TOP/XP/XP_BAR.value = current_xp


func _on_game_context_current_time(time_minute: Variant, time_seconde: Variant) -> void:
	$TOP/MainHud/GameTimer.text = "[center][b]" + str(time_minute) + " : " + str(time_seconde) + "[/b][/center]"


func _on_enemy_generator_enemy_died(numbers: Variant) -> void:
	$TOP/MainHud/Stats/Kills/Kills_Label.text = " : " + str(numbers)


func _on_player_dollar_gained(dollars: Variant) -> void:
	current_dollars += dollars
	$TOP/MainHud/Stats/Money/Money_Label.text = " : " + str(current_dollars)
