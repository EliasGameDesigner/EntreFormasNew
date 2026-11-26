extends CanvasLayer
## Non-modal dialogue: only the dismiss/resume buttons consume clicks.
@export var tutorial: ArtTutorial
var panel: PanelContainer
var portrait: TextureRect
var heading: Label
var speech: Label
var objective: Label
var dismiss_button: Button
var resume_button: Button
var show_text_button: Button
var typewriter: Node
var _root: Control

func _ready() -> void:
	layer = 55
	process_priority = 90
	add_to_group("art_tutorial_ui")
	_root = Control.new()
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = preload("res://ui/machine_repair/workbench_theme.gd").create()
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(panel)
	var skin = preload("res://ui/machine_repair/workbench_theme.gd").box("ead7ac", "9c793f", 3)
	skin.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", skin)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)
	var art_column := VBoxContainer.new()
	art_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(art_column)
	portrait = TextureRect.new()
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait.texture = preload("res://assets/textures/characters/art_top_hat_v1.png")
	portrait.custom_minimum_size = Vector2(84, 84)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art_column.add_child(portrait)
	var name_label := _label(art_column, 24)
	name_label.text = "ART"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 5)
	row.add_child(column)
	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(header)
	heading = _label(header, 24)
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dismiss_button = Button.new()
	dismiss_button.text = "Dispensar"
	dismiss_button.add_theme_font_size_override("font_size", 18)
	dismiss_button.pressed.connect(tutorial.dismiss)
	header.add_child(dismiss_button)
	speech = _label(column, 22)
	speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective = _label(column, 22)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective.add_theme_color_override("font_color", Color("62431d"))
	typewriter = preload("res://ui/dialogue/typewriter_text.gd").new()
	typewriter.label = speech
	add_child(typewriter)
	show_text_button = Button.new()
	show_text_button.text = "Mostrar tudo"
	show_text_button.add_theme_font_size_override("font_size", 18)
	show_text_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	show_text_button.pressed.connect(typewriter.finish)
	column.add_child(show_text_button)
	typewriter.finished.connect(func(): show_text_button.disabled = true)
	resume_button = Button.new()
	resume_button.text = "Art: mostrar dica"
	resume_button.add_theme_font_size_override("font_size", 22)
	resume_button.pressed.connect(tutorial.resume)
	_root.add_child(resume_button)
	tutorial.changed.connect(_refresh)
	_refresh()

func _label(parent: Control, font_size: int) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("35281b"))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	parent.add_child(label)
	return label

func _refresh() -> void:
	visible = tutorial.available()
	panel.visible = visible and not tutorial.dismissed
	resume_button.visible = visible and tutorial.dismissed
	var hint := tutorial.hint()
	heading.text = hint.title
	typewriter.set_message(hint.text, str(tutorial.step))
	typewriter.set_active(visible and panel.visible)
	show_text_button.disabled = not typewriter.is_typing()
	objective.text = hint.goal
	dismiss_button.text = "Concluir" if tutorial.step == &"complete" else "Dispensar"
	_layout()

func _layout() -> void:
	var screen := get_viewport().get_visible_rect().size
	var bench_ui = tutorial.cycle.mold_workbench.ui
	var in_workbench: bool = bench_ui.visible
	var width := minf(560.0, screen.x - 32)
	if in_workbench:
		width = minf(390.0, bench_ui.board.size.x - 24)
	portrait.custom_minimum_size = Vector2(64, 64) if in_workbench else Vector2(84, 84)
	panel.custom_minimum_size.x = width
	panel.size.x = width
	panel.reset_size()
	panel.position = Vector2((screen.x - panel.size.x) / 2, screen.y - panel.size.y - 16).round()
	if in_workbench:
		var board_rect: Rect2 = bench_ui.board.get_global_rect()
		panel.position = Vector2(board_rect.end.x - panel.size.x - 12, board_rect.position.y + 12).round()
	resume_button.reset_size()
	resume_button.position = Vector2(screen.x - resume_button.size.x - 16, screen.y - resume_button.size.y - 16)

func _process(_delta: float) -> void:
	if visible:
		_layout()
