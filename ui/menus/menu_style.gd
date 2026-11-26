extends RefCounted
## Shared workshop materials and typography for the title and pause screens.
const SKIN = preload("res://ui/machine_repair/workbench_theme.gd")

static func card(parent: Node, width: float) -> VBoxContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = width
	panel.add_theme_stylebox_override("panel", SKIN.box("30251c", "a28249", 3))
	parent.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	panel.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 16)
	margin.add_child(column)
	return column

static func label(parent: Node, text: String, font_size: int) -> Label:
	var result := Label.new()
	result.text = text
	result.add_theme_font_size_override("font_size", font_size)
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(result)
	return result

static func button(parent: Node, text: String, action: Callable) -> Button:
	var result := Button.new()
	result.text = text
	result.custom_minimum_size = Vector2(280, 48)
	result.add_theme_font_size_override("font_size", 28)
	result.pressed.connect(action)
	parent.add_child(result)
	return result
