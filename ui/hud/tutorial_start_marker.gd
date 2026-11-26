extends CanvasLayer
## Pins a direction to the counter before the first lesson; never accepts clicks.
@export var cycle: FirstCycle
@export var counter: Node2D
var panel: PanelContainer
var caption: Label
var pinned := false

func _ready() -> void:
	layer = 46
	process_priority = 110
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = preload("res://ui/machine_repair/workbench_theme.gd").create()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size.x = 264
	root.add_child(panel)
	var skin = preload("res://ui/machine_repair/workbench_theme.gd").box("efdbaf", "b58b42", 3)
	panel.add_theme_stylebox_override("panel", skin)
	caption = Label.new()
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 26)
	caption.add_theme_color_override("font_color", Color("3d2b18"))
	caption.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	panel.add_child(caption)
	cycle.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	visible = cycle.initial_tutorial_pending()

func _process(_delta: float) -> void:
	panel.visible = get_tree().get_first_node_in_group("modal_repair_ui") == null
	if not visible or not panel.visible:
		return
	var screen := get_viewport().get_visible_rect()
	var destination := counter.get_global_transform_with_canvas() * Vector2.ZERO
	pinned = not screen.grow(-32).has_point(destination)
	var arrow := "↓"
	if pinned:
		var direction := destination - screen.get_center()
		if absf(direction.x) >= absf(direction.y):
			arrow = "→" if direction.x > 0 else "←"
		else:
			arrow = "↓" if direction.y > 0 else "↑"
	caption.text = "INICIAR TUTORIAL " + arrow + "\nBalcão de atendimento"
	panel.reset_size()
	var minimum := Vector2(252, 132)
	var maximum := (screen.size - panel.size - Vector2(16, 16)).max(minimum)
	var head := counter.get_global_transform_with_canvas() * Vector2(0, -140)
	panel.position = (head - Vector2(panel.size.x / 2, panel.size.y + 10)).clamp(minimum, maximum).round()
	var art = get_tree().get_first_node_in_group("art_tutorial_ui")
	if art != null and art.visible and art.panel.visible and panel.get_global_rect().intersects(art.panel.get_global_rect()):
		panel.position.y = maxf(minimum.y, art.panel.position.y - panel.size.y - 12)
