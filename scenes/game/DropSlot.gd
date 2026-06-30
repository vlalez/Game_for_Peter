class_name DropSlot
extends Control
## A square target for one letter. Accepts a LetterTile only when the tile's
## letter matches this slot and the slot is still empty; otherwise the tile
## snaps back to where it came from.

signal filled

var expected_letter: String = ""
var _filled: bool = false


func is_filled() -> bool:
	return _filled


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if _filled:
		return false
	if typeof(data) != TYPE_DICTIONARY:
		return false
	return data.get("letter", "") == expected_letter


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var tile: LetterTile = data["tile"]
	tile.placed = true
	tile.get_parent().remove_child(tile)
	add_child(tile)
	tile.set_anchors_preset(Control.PRESET_FULL_RECT)
	tile.offset_left = 0.0
	tile.offset_top = 0.0
	tile.offset_right = 0.0
	tile.offset_bottom = 0.0
	_filled = true
	filled.emit()
