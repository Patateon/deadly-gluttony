extends TabContainer
@export var pre_scene: Node
@onready var menuButton: VBoxContainer = $"../MainMenu/VBoxContainer"

func _ready():
	hide()


func _on_back_pressed() -> void:
	hide()
	menuButton.show()
