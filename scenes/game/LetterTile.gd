class_name LetterTile
extends Control
## A draggable square tile showing one letter. Dragging starts here; the
## target DropSlot decides whether the drop is accepted.

@onready var _label: Label = %Label

var letter: String = "":
	set(value):
		letter = value
		if is_node_ready():
			_label.text = value
var placed: bool = false  ## true once snapped into a slot; blocks further drags


func _ready() -> void:
	_label.text = letter


func set_font_size(size: int) -> void:
	_label.add_theme_font_size_override("font_size", size)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if placed:
		return null
	set_drag_preview(_make_preview())
	return {"letter": letter, "tile": self}


func _make_preview() -> Control:
	var preview := Panel.new()
	preview.custom_minimum_size = size
	preview.size = size
	preview.modulate = Color(1, 1, 1, 0.85)
	var label := Label.new()
	label.text = letter
	label.add_theme_font_size_override(
		"font_size", _label.get_theme_font_size("font_size")
	)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview.add_child(label)
	return preview
