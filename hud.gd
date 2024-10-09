extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TOP/Level_Label.text = "[b]LVL : 1 [/b]"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_level_gained(level: Variant) -> void:
	$TOP/Level_Label.text = "[b]LVL : " + str(level) + "[/b]"


func _on_player_xp_gained(current_xp: Variant, max_xp: Variant) -> void:
	$TOP/XP_BAR/XP_Numbers.text = "[center][b]" + str(int(current_xp))\
								  + "/" + str(int(max_xp)) + "[/b][/center]"
	$TOP/XP_BAR.max_value = max_xp
	$TOP/XP_BAR.value = current_xp
