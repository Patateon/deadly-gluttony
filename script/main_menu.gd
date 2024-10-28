extends Control
@onready var option_menu: TabContainer = $"../Settings"
@onready var Credit_menu: TabContainer = $"../Credits"


func _ready():
	$VBoxContainer/Start.grab_focus()

func reset_focus():
	$VBoxContainer/Start.grab_focus()

func _on_start_pressed():
	Utilities.switch_scene("world", self)
	AudioManager.selectmusic(0)

func _on_option_pressed():
	$VBoxContainer.hide()
	option_menu.show()
	option_menu.reset_focus()


func _on_quit_pressed():
	get_tree().quit()


func _on_creditt_pressed() -> void:
	$VBoxContainer.hide()
	Credit_menu.show()
	option_menu.reset_focus()
