extends Control
## Placeholder gameplay scene. Real tile/slot gameplay arrives in a later
## increment; for now it only offers a way back to the start screen.

@onready var _back_button: Button = %BackButton


func _ready() -> void:
	_back_button.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	SceneLoader.go_to_start()
