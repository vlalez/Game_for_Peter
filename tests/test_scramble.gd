extends GutTest
## Tests for GameScene._scramble() — letter preservation and order randomisation.
##
## GameScene extends Control, so we instantiate a bare Control with the script
## attached but never add it to the scene tree. This avoids triggering _ready()
## (which needs @onready UI nodes) while still letting us call the pure _scramble().

const GameSceneScript := preload("res://scenes/game/GameScene.gd")

var _scene: Control


func before_each() -> void:
	_scene = Control.new()
	_scene.set_script(GameSceneScript)


func after_each() -> void:
	_scene.free()


func test_preserves_all_letters_cat() -> void:
	var result: Array = _scene._scramble("CAT")
	assert_eq(result.size(), 3, "Should return 3 letters for CAT")
	assert_true(result.has("C"), "Should contain C")
	assert_true(result.has("A"), "Should contain A")
	assert_true(result.has("T"), "Should contain T")


func test_preserves_all_letters_sunflower() -> void:
	var word := "SUNFLOWER"
	var result: Array = _scene._scramble(word)
	assert_eq(result.size(), word.length(), "Should return same number of letters")
	for i in word.length():
		var ch: String = word[i]
		assert_true(result.has(ch), "Should contain letter: " + ch)


func test_no_letters_added() -> void:
	var result: Array = _scene._scramble("DOG")
	assert_eq(result.size(), 3, "Should not add extra letters")


func test_scramble_differs_from_original() -> void:
	# Run up to 20 times — probability of all same-order is (1/6!)^20 ≈ 0
	var word := "DRAGON"
	var original: Array = []
	for i in word.length():
		original.append(word[i])
	var ever_different := false
	for _attempt in 20:
		var result: Array = _scene._scramble(word)
		if result != original:
			ever_different = true
			break
	assert_true(ever_different, "Scramble should produce a different order at least once in 20 tries")


func test_single_letter_returns_unchanged() -> void:
	var result: Array = _scene._scramble("A")
	assert_eq(result.size(), 1, "Single letter should return array of size 1")
	assert_eq(result[0], "A", "Single letter should be unchanged")


func test_two_letters_always_differ() -> void:
	# For a 2-letter word the only other permutation is the swap,
	# which _scramble should find within 10 attempts.
	var word := "BE"
	var original := ["B", "E"]
	var ever_different := false
	for _attempt in 20:
		var result: Array = _scene._scramble(word)
		if result != original:
			ever_different = true
			break
	assert_true(ever_different, "Two-letter scramble should swap at least once in 20 tries")


func test_duplicate_letters_preserved() -> void:
	# BEE has two E's — both must appear in the result
	var result: Array = _scene._scramble("BEE")
	assert_eq(result.size(), 3, "BEE scramble should return 3 letters")
	var e_count: int = 0
	for ch in result:
		if ch == "E":
			e_count += 1
	assert_eq(e_count, 2, "BEE scramble should contain exactly 2 E's")
