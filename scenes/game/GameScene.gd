extends Control
## Orchestrates one spelling round: shows the word image, spawns scrambled
## letter tiles and matching drop slots, advances when the word is solved,
## and quits the app on confirmed quit.

const WORDS_DIR: String = "res://resources/words/"
const SUCCESS_SOUND_PATH: String = "res://resources/audio/success.wav"
const TILE_SCENE: PackedScene = preload("res://scenes/game/LetterTile.tscn")
const SLOT_SCENE: PackedScene = preload("res://scenes/game/DropSlot.tscn")
const MIN_FONT_SIZE: int = 24
const MAX_FONT_SIZE: int = 48
const MIN_WORD_LEN: int = 3
const MAX_WORD_LEN: int = 9
const NEXT_WORD_DELAY: float = 1.0
const DESIGN_WIDTH: int = 720
const CONTENT_MARGIN: int = 24
const TILE_SEPARATION: int = 12
const MIN_TILE_WIDTH: int = 60
const MAX_TILE_WIDTH: int = 150

@onready var _image: TextureRect = %WordImage
@onready var _tiles: HBoxContainer = %TilesContainer
@onready var _slots: HBoxContainer = %SlotsContainer
@onready var _quit_button: Button = %QuitButton
@onready var _quit_dialog: ConfirmationDialog = %QuitDialog

var _words: Array[WordData] = []
var _index: int = 0
var _solved_count: int = 0
var _success_sound: AudioStream


func _ready() -> void:
	_quit_button.pressed.connect(_on_quit_pressed)
	_quit_dialog.confirmed.connect(_on_quit_confirmed)
	if ResourceLoader.exists(SUCCESS_SOUND_PATH):
		_success_sound = load(SUCCESS_SOUND_PATH)
	_words = _load_words()
	if not _words.is_empty():
		_load_word(_words[_index])


## Load every WordData under resources/words/ in random order.
func _load_words() -> Array[WordData]:
	var result: Array[WordData] = []
	var dir := DirAccess.open(WORDS_DIR)
	if dir == null:
		return result
	for file in dir.get_files():
		if not file.ends_with(".tres"):
			continue
		var data := load(WORDS_DIR + file) as WordData
		if data != null and data.word != "":
			result.append(data)
	result.shuffle()
	return result


func _load_word(data: WordData) -> void:
	_clear_children(_tiles)
	_clear_children(_slots)
	_solved_count = 0
	if data == null:
		return
	_image.texture = data.image
	var word: String = data.word.to_upper()
	var font_size: int = _font_size_for(word.length())
	var tile_width: int = _tile_width_for(word.length())
	_build_slots(word, tile_width)
	_build_tiles(_scramble(word), font_size, tile_width)


func _build_slots(word: String, tile_width: int) -> void:
	for i in word.length():
		var slot := SLOT_SCENE.instantiate() as DropSlot
		slot.expected_letter = word[i]
		slot.custom_minimum_size = Vector2(tile_width, slot.custom_minimum_size.y)
		slot.filled.connect(_on_slot_filled)
		_slots.add_child(slot)


func _build_tiles(letters: Array, font_size: int, tile_width: int) -> void:
	for ch in letters:
		var tile := TILE_SCENE.instantiate() as LetterTile
		tile.letter = ch
		tile.custom_minimum_size = Vector2(tile_width, tile.custom_minimum_size.y)
		_tiles.add_child(tile)
		tile.set_font_size(font_size)


## Return the word's letters in a randomized order, avoiding the original order.
func _scramble(word: String) -> Array:
	var letters: Array = []
	for i in word.length():
		letters.append(word[i])
	if letters.size() < 2:
		return letters
	var original := letters.duplicate()
	for _attempt in 10:
		letters.shuffle()
		if letters != original:
			break
	return letters


func _font_size_for(length: int) -> int:
	if length <= MIN_WORD_LEN:
		return MAX_FONT_SIZE
	if length >= MAX_WORD_LEN:
		return MIN_FONT_SIZE
	var t := float(length - MIN_WORD_LEN) / float(MAX_WORD_LEN - MIN_WORD_LEN)
	return int(round(lerp(float(MAX_FONT_SIZE), float(MIN_FONT_SIZE), t)))


## Fixed per-tile width so tiles keep their size as siblings are removed.
func _tile_width_for(count: int) -> int:
	var usable: int = DESIGN_WIDTH - 2 * CONTENT_MARGIN - TILE_SEPARATION * (count - 1)
	return clampi(usable / count, MIN_TILE_WIDTH, MAX_TILE_WIDTH)


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _on_slot_filled() -> void:
	_solved_count += 1
	if _solved_count == _slots.get_child_count():
		_on_word_solved()


func _on_word_solved() -> void:
	AudioManager.play(_success_sound)
	await get_tree().create_timer(NEXT_WORD_DELAY).timeout
	_index = (_index + 1) % _words.size()
	_load_word(_words[_index])


func _on_quit_pressed() -> void:
	_quit_dialog.popup_centered()


func _on_quit_confirmed() -> void:
	get_tree().quit()
