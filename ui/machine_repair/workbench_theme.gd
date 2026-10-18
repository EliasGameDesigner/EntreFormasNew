extends RefCounted
## Native UI skin: readable text, worn wood colors, iron buttons and brass edges.

static func box(fill: String, edge: String, width: int = 2) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(fill)
	style.border_color = Color(edge)
	style.set_border_width_all(width)
	style.set_corner_radius_all(2)
	style.set_content_margin_all(10)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 3)
	return style

static func create() -> Theme:
	var theme := Theme.new()
	theme.default_font_size = 16
	theme.set_color("font_color", "Label", Color("f1dfb7"))
	theme.set_color("font_shadow_color", "Label", Color("201710"))
	theme.set_constant("shadow_offset_y", "Label", 1)
	theme.set_stylebox("normal", "Button", box("343733", "8d7143"))
	theme.set_stylebox("hover", "Button", box("4b4c3d", "dbb96f"))
	theme.set_stylebox("pressed", "Button", box("232722", "b5965b"))
	theme.set_stylebox("disabled", "Button", box("302c25", "594a34"))
	var focus := box("00000000", "efd18b")
	focus.shadow_size = 0
	theme.set_stylebox("focus", "Button", focus)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		theme.set_color(state, "Button", Color("f4e2b8"))
	theme.set_color("font_disabled_color", "Button", Color("94866d"))
	return theme
