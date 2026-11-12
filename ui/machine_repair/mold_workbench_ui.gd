extends CanvasLayer
## One persistent shelf; recipe selection only controls the optional guide.
var workbench: Node
var board
var panel: PanelContainer
var choices: VBoxContainer
var title: Label
var instructions: Label
var order_status: Label
var status: Label
var close_button: Button
var discard_button: Button
var shape_buttons: Dictionary = {}
var recipe_buttons: Dictionary = {}
var guide: CheckButton
var selected_recipe: StringName = &"square"
const PIECES = {
	&"trapezoid": preload("res://data/items/shape_trapezoid.tres"),
	&"parallelogram": preload("res://data/items/shape_parallelogram.tres"),
	&"triangle": preload("res://data/items/shape_triangle.tres"),
	&"square": preload("res://data/items/shape_square.tres"),
	&"rectangle": preload("res://data/items/shape_rectangle.tres"),
}

func _ready() -> void:
	layer = 50
	var root := Control.new()
	root.theme = preload("res://ui/machine_repair/workbench_theme.gd").create()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var shade := ColorRect.new()
	root.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.03, 0.04, 0.07, 0.72)
	panel = PanelContainer.new()
	root.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 24
	panel.offset_right = -24
	panel.offset_top = 24
	panel.offset_bottom = -24
	var style := StyleBoxFlat.new()
	style.bg_color = Color("42301f")
	style.border_color = Color("ad8950")
	style.set_border_width_all(4)
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
	order_status = Label.new()
	order_status.add_theme_font_size_override("font_size", 14)
	header.add_child(order_status)
	close_button = Button.new()
	close_button.text = "Fechar"
	close_button.pressed.connect(close_ui)
	header.add_child(close_button)
	instructions = Label.new()
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(instructions)
	var workspace := HBoxContainer.new()
	workspace.size_flags_vertical = Control.SIZE_EXPAND_FILL
	workspace.add_theme_constant_override("separation", 18)
	box.add_child(workspace)
	choices = VBoxContainer.new()
	choices.custom_minimum_size.x = 190
	workspace.add_child(choices)
	var shelf_title := Label.new()
	shelf_title.text = "MOLDES DISPONÍVEIS"
	choices.add_child(shelf_title)
	for shape in workbench.PRODUCTS:
		var button = preload("res://ui/machine_repair/mold_supply_button.gd").new()
		button.custom_minimum_size = Vector2(190, 56)
		button.piece_data = PIECES.get(shape)
		if shape in [&"triangle", &"square", &"rectangle", &"parallelogram", &"trapezoid"]:
			button.icon = load("res://data/items/%s_mold_texture.tres" % shape)
			button.expand_icon = true
			button.add_theme_constant_override("icon_max_width", 40)
			button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		button.tooltip_text = "Arraste para montar. Clique para carregar até a máquina."
		button.pressed.connect(func(): workbench.take_stored(shape))
		choices.add_child(button)
		shape_buttons[shape] = button
	discard_button = Button.new()
	discard_button.text = "Largar molde das mãos"
	discard_button.pressed.connect(workbench.discard_carried)
	choices.add_child(discard_button)
	var return_button := Button.new()
	return_button.text = "Guardar peças da mesa"
	return_button.pressed.connect(_return_pieces)
	choices.add_child(return_button)
	board = preload("res://ui/machine_repair/free_mold_board.gd").new()
	board.workshop_style = true
	board.custom_minimum_size = Vector2(680, 280)
	board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	workspace.add_child(board)
	board.assembly_completed.connect(func(): workbench.complete_step.call_deferred())
	board.board_changed.connect(_refresh_progress)
	board.mold_assembled.connect(workbench.store_assembled)
	board.supply_requested.connect(_supply_piece)
	var recipes := HFlowContainer.new()
	box.add_child(recipes)
	var recipe_title := Label.new()
	recipe_title.text = "RECEITAS  "
	recipes.add_child(recipe_title)
	for shape in workbench.RECIPES:
		var button := Button.new()
		button.text = {&"square": "2 triângulos → Quadrado", &"rectangle": "2 quadrados → Retângulo", &"parallelogram": "2 triângulos → Paralelogramo", &"trapezoid": "1 quadrado + 2 triângulos → Trapézio"}[shape]
		button.pressed.connect(func():
			selected_recipe = shape
			guide.button_pressed = true
			_update_hint())
		recipes.add_child(button)
		recipe_buttons[shape] = button
	guide = CheckButton.new()
	guide.text = "Mostrar guia"
	guide.toggled.connect(func(_value): _update_hint())
	recipes.add_child(guide)
	status = Label.new()
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(status)
	workbench.changed.connect(_refresh_stock)
	hide()

func open_ui() -> void:
	add_to_group("modal_repair_ui")
	show()
	show_choices()

func show_choices() -> void:
	_return_pieces()
	board.clear()
	board.free_mode = true
	board.available_shapes.assign(workbench.available_shapes)
	board.show()
	choices.show()
	title.text = "BANCADA DE MOLDES"
	instructions.text = "Arraste moldes da esquerda para montar • Duplo clique: girar\nClique em um molde da lista para levá-lo à máquina."
	_refresh_stock()
	_update_hint()

func _supply_piece(data: ShapePieceData, at_position: Vector2) -> void:
	if not visible or not board.free_mode or not PIECES.values().has(data):
		return
	if workbench.supply(data.shape_id):
		var piece: ShapePiece = board.add_piece(data, at_position.clamp(Vector2(80, 80), board.size - Vector2(80, 80)))
		board.try_snap(piece)

func _return_pieces() -> void:
	if not board.free_mode:
		return
	for piece in board.pieces:
		workbench.return_mold(piece.definition.shape_id)
	board.clear()
	board.queue_redraw()

func _refresh_stock() -> void:
	for shape in shape_buttons:
		var button: Button = shape_buttons[shape]
		button.disabled = not workbench.can_supply(shape)
		var count := "∞" if workbench.can_take_ready(shape) else str(workbench.stored_molds.get(shape, 0))
		button.text = workbench.NAMES[shape] + "  × " + count
		if not workbench.available_shapes.has(shape):
			button.text += "\nPróximo ciclo"
	for shape in recipe_buttons:
		recipe_buttons[shape].disabled = not workbench.available_shapes.has(shape)
	discard_button.visible = workbench.carried_mold != &""
	_refresh_progress()

func _update_hint() -> void:
	board.set_hint(workbench.RECIPES.get(selected_recipe) if guide.button_pressed and workbench.available_shapes.has(selected_recipe) else null)

## Compatibility for scripted, sequential assembly callers.
func show_step(recipe: AssemblyDefinition, index: int, total: int) -> void:
	_return_pieces()
	board.free_mode = false
	title.text = "MOLDE DE %s • Etapa %d/%d" % [recipe.title.to_upper(), index, total]
	choices.hide()
	discard_button.hide()
	instructions.text = recipe.instructions + "\nMouse1: arrastar • Duplo clique: girar • Esc: cancelar preparação"
	board.show()
	board.setup(recipe, true)
	_refresh_progress()

func _refresh_progress() -> void:
	if not is_instance_valid(status):
		return
	if board.free_mode:
		status.text = "Moldes prontos voltam à lista • O prazo do pedido continua correndo."
	elif board.definition != null:
		status.text = "Encaixes: %d/%d • O prazo do pedido continua correndo." % [board.get_filled_count(), board.get_required_count()]

func close_ui() -> void:
	_return_pieces()
	workbench.cancel_assembly()
	board.clear()
	if is_in_group("modal_repair_ui"):
		remove_from_group("modal_repair_ui")
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_ui()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if not visible:
		return
	var cycle = get_tree().get_first_node_in_group("first_cycle")
	if cycle == null:
		return
	order_status.text = "Ciclo %d • %02d:%02d" % [cycle.cycle_number, floori(cycle.time_left / 60), int(cycle.time_left) % 60]
	if cycle.order_item != null:
		order_status.text += "\n%d × %s • %ds" % [cycle.order_quantity, cycle.order_item.item_name, ceili(cycle.order_time_left)]
