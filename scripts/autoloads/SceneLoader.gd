extends Node
## Singleton for all scene transitions. Gameplay scripts must change scenes
## through this manager rather than calling get_tree().change_scene_to_file().

const START_SCENE: String = "res://scenes/start/StartScene.tscn"
const GAME_SCENE: String = "res://scenes/game/GameScene.tscn"


func go_to_start() -> void:
	get_tree().change_scene_to_file(START_SCENE)


func go_to_game() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)
