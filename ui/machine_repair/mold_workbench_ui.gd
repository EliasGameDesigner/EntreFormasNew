extends CanvasLayer
## Assembly board host for molds: never accesses the product inventory.

var workbench: Node
var board: ShapeAssemblyBoard
var panel: PanelContainer
var choices: HBoxContainer
var title: Label
var instructions: Label
var status: Label
var close_button: Button
var discard_button: Button
var shape_buttons: Dictionary = {}

func _ready() -> void:
	layer = 30
	var root := Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.03, 0.04, 0.07, 0.72)
	panel = PanelContainer.new()
	root.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel.offset_left = -380
	panel.offset_right = 380
	panel.offset_top = 110
	panel.offset_bottom = 610
	var style := StyleBoxFlat.new()
	style.bg_color = Color("141e2b")
	style.border_color = Color("74cbd5")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	var header := HBoxContainer.new()
	box.add_child(header)
	title = Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	header.add_child(title)
	close_button = Button.new()
	close_button.text = "Fechar"
	close_button.pressed.connect(close_ui)
	header.add_child(close_button)
	instructions = Label.new()
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(instructions)
	choices = HBoxContainer.new()
	choices.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(choices)
	for shape in workbench.PRODUCTS:
		var button := Button.new()
		button.custom_minimum_size = Vector2(190, 50)
		button.pressed.connect(func(): workbench.begin_mold(shape))
		choices.add_child(button)
		shape_buttons[shape] = button
	discard_button = Button.new()
	discard_button.text = "Descartar molde carregado"
	discard_button.pressed.connect(workbench.discard_carried)
	box.add_child(discard_button)
	var center := CenterContainer.new()
	box.add_child(center)
	board = ShapeAssemblyBoard.new()
	center.add_child(board)
	board.assembly_completed.connect(func(): workbench.complete_step.call_deferred())
	board.board_changed.connect(_refresh_progress)
	status = Label.new()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(status)
	hide()

func open_ui() -> void:
	add_to_group("modal_repair_ui")
	show()
	show_choices()

func show_choices() -> void:
	title.text = "BANCADA DE MOLDES"
	board.clear()
	board.hide()
	panel.offset_bottom = 390
	choices.show()
	var carrying: bool = workbench.carried_mold != &""
	discard_button.visible = carrying
	for shape in shape_buttons:
		var button: Button = shape_buttons[shape]
		button.disabled = carrying or not workbench.available_shapes.has(shape)
		button.text = ("Pegar " if workbench.can_take_ready(shape) else "Montar ") + workbench.NAMES[shape]
		if not workbench.available_shapes.has(shape):
			button.text += "\nPróximo ciclo"
	instructions.text = "O molde de triângulo está sempre disponível.\nMonte os outros moldes e carregue um por vez até a máquina."
	status.text = "Nas mãos: " + workbench.NAMES[workbench.carried_mold] if carrying else "Moldes são separados dos produtos. Cada fabricação consome um molde."

func show_step(recipe: AssemblyDefinition, index: int, total: int) -> void:
	panel.offset_bottom = 610
	title.text = "MOLDE DE %s • Etapa %d/%d" % [recipe.title.to_upper(), index, total]
	choices.hide()
	discard_button.hide()
	instructions.text = recipe.instructions + "\nMouse1: arrastar • R: girar • Esc: cancelar preparação"
	board.show()
	board.setup(recipe, true)
	_refresh_progress()

func _refresh_progress() -> void:
	if is_instance_valid(status) and board.definition != null:
		status.text = "Encaixes: %d/%d • O prazo do pedido continua correndo." % [board.get_filled_count(), board.get_required_count()]

func close_ui() -> void:
	workbench.cancel_assembly()
	board.clear()
	if is_in_group("modal_repair_ui"):
		remove_from_group("modal_repair_ui")
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_ui()
		get_viewport().set_input_as_handled()
