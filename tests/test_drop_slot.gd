extends GutTest
## Tests for DropSlot letter-matching and fill-state logic.

const DropSlotScene := preload("res://scenes/game/DropSlot.tscn")

var _slot: DropSlot


func before_each() -> void:
	_slot = DropSlotScene.instantiate()
	_slot.expected_letter = "A"
	add_child_autofree(_slot)


func test_is_filled_initially_false() -> void:
	assert_false(_slot.is_filled(), "New slot should not be filled")


func test_can_drop_matching_letter() -> void:
	var data := {"letter": "A", "tile": null}
	assert_true(_slot._can_drop_data(Vector2.ZERO, data), "Should accept matching letter")


func test_rejects_wrong_letter() -> void:
	var data := {"letter": "B", "tile": null}
	assert_false(_slot._can_drop_data(Vector2.ZERO, data), "Should reject non-matching letter")


func test_rejects_empty_letter() -> void:
	var data := {"letter": "", "tile": null}
	assert_false(_slot._can_drop_data(Vector2.ZERO, data), "Should reject empty letter")


func test_rejects_non_dictionary_data() -> void:
	assert_false(_slot._can_drop_data(Vector2.ZERO, "A"), "Should reject non-dict data")
	assert_false(_slot._can_drop_data(Vector2.ZERO, null), "Should reject null data")
	assert_false(_slot._can_drop_data(Vector2.ZERO, 42), "Should reject int data")


func test_rejects_when_already_filled() -> void:
	_slot._filled = true
	var data := {"letter": "A", "tile": null}
	assert_false(_slot._can_drop_data(Vector2.ZERO, data), "Filled slot should reject all drops")


func test_case_sensitive_matching() -> void:
	var lower := {"letter": "a", "tile": null}
	assert_false(_slot._can_drop_data(Vector2.ZERO, lower), "Match must be case-sensitive")


func test_expected_letter_empty_rejects_everything() -> void:
	_slot.expected_letter = ""
	var data := {"letter": "", "tile": null}
	assert_false(_slot._can_drop_data(Vector2.ZERO, data), "Empty expected_letter should reject empty-letter drop")
