extends Node
## Singleton for all sound playback. Gameplay scripts must play audio through
## this manager rather than creating AudioStreamPlayer nodes directly.

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)


## Play a one-shot sound. Does nothing when the stream is null.
func play(stream: AudioStream) -> void:
	if stream == null:
		return
	_player.stream = stream
	_player.play()
