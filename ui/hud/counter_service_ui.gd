extends CanvasLayer
## Open the next timed service from the customer counter.
var cycle: FirstCycle
var start_cycle_button: Button
var title: Label

func _ready() -> void:
	layer = 50
	var root := Control.new()
	root.theme = preload("res://ui/machine_repair/workbench_theme.gd").create()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.65)
	var panel := PanelContainer.new()
	root.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -250
	panel.offset_right = 250
	panel.offset_top = -150
	panel.offset_bottom = 150
	var style := StyleBoxFlat.new()
	style.bg_color = Color("42301f")
	style.border_color = Color("ad8950")
	style.set_border_width_all(3)
	style.set_content_margin_all(22)
	panel.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	panel.add_child(column)
	title = Label.new()
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	column.add_child(title)
	var explanation := Label.new()
	explanation.text = "Os clientes chegam quando você iniciar.\nVocê pode voltar e continuar se preparando."
	explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	column.add_child(explanation)
	start_cycle_button = Button.new()
	start_cycle_button.custom_minimum_size.y = 48
	start_cycle_button.pressed.connect(_start_cycle)
	column.add_child(start_cycle_button)
	var close_button := Button.new()
	close_button.text = "Continuar preparando"
	close_button.pressed.connect(close_ui)
	column.add_child(close_button)
	hide()

func open_ui() -> void:
	if not cycle.preparing or get_tree().get_first_node_in_group("modal_repair_ui") != null:
		return
	title.text = "BALCÃO DE ATENDIMENTO"
	start_cycle_button.text = "Iniciar ciclo %d" % cycle.pending_cycle_number()
	add_to_group("modal_repair_ui")
	show()

func close_ui() -> void:
	remove_from_group("modal_repair_ui")
	hide()

func _start_cycle() -> void:
	if not visible or not cycle.preparing:
		return
	close_ui()
	cycle.start_prepared_cycle()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_ui()
		get_viewport().set_input_as_handled()
