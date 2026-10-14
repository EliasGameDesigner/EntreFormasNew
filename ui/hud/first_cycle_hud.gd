extends CanvasLayer

@export var cycle: FirstCycle
var _order: Label
var _stock: Label
var _clock: Label
var _patience: ProgressBar
var _overlay: ColorRect
var _intro: Label
var _button: Button
var _notification_position: Vector2
var _notification_size: Vector2
var _root: Control
var _stock_panel: PanelContainer
var _order_panel: PanelContainer
var _clock_panel: PanelContainer

func _ready() -> void:
	layer = 40
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	_root = root
	_stock_panel = _panel(root, Control.PRESET_TOP_LEFT, 16, 188)
	_order_panel = _panel(root, Control.PRESET_TOP_RIGHT, -188, -16)
	_clock_panel = _panel(root, Control.PRESET_CENTER_TOP, -175, 175)
	_stock = _label(_stock_panel, 16)
	_stock.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_clock = _label(_clock_panel, 17)
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var order_column := VBoxContainer.new()
	_order_panel.add_child(order_column)
	_order = _label(order_column, 16)
	_order.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_patience = ProgressBar.new()
	_patience.custom_minimum_size = Vector2(0, 12)
	_patience.show_percentage = false
	order_column.add_child(_patience)
	var controls := _label(root, 15)
	controls.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	controls.offset_top = -30
	controls.offset_bottom = -8
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.text = "WASD: mover   •   Mouse1: interagir   •   R: girar peça   •   F11: tela cheia/janela"
	_overlay = ColorRect.new()
	_overlay.color = Color(0.025, 0.04, 0.07, 0.94)
	root.add_child(_overlay)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	_overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)
	_intro = _label(box, 22)
	_intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button = Button.new()
	_button.custom_minimum_size.y = 52
	box.add_child(_button)
	_button.pressed.connect(_start)
	cycle.changed.connect(_refresh)
	InventoryManager.inventory_changed.connect(_refresh)
	if is_instance_valid(cycle.mold_workbench):
		cycle.mold_workbench.changed.connect(_refresh)
	GameUI.get_node("Control/MarginContainer").hide()
	_notification_position = GameUI.notification_label.position
	_notification_size = GameUI.notification_label.size
	GameUI.notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	get_viewport().size_changed.connect(_layout_notifications)
	_layout_notifications()
	_refresh()

func _panel(parent: Control, preset: Control.LayoutPreset, left: float, right: float) -> PanelContainer:
	var panel := PanelContainer.new()
	parent.add_child(panel)
	panel.set_anchors_and_offsets_preset(preset)
	panel.offset_left = left
	panel.offset_right = right
	panel.offset_top = 16
	panel.offset_bottom = 90
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.12, 0.17, 0.94)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(12)
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _layout_notifications() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	GameUI.notification_label.position = Vector2(16, viewport_size.y - 76)
	GameUI.notification_label.size = Vector2(viewport_size.x - 32, 40)

func _exit_tree() -> void:
	if is_instance_valid(GameUI):
		GameUI.get_node("Control/MarginContainer").show()
		GameUI.notification_label.position = _notification_position
		GameUI.notification_label.size = _notification_size
		GameUI.notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

func _label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
	return label

func _start() -> void:
	_overlay.hide()
	if _overlay.is_in_group("modal_repair_ui"):
		_overlay.remove_from_group("modal_repair_ui")
	cycle.start_round()

func _refresh() -> void:
	if not is_instance_valid(_order):
		return
	var stock := InventoryManager.get_all_items()
	_stock.text = "PRODUTOS\nTriângulos: %d\nQuadrados: %d\nMoedas: $%d" % [stock.get(FirstCycle.TRIANGLE, 0), stock.get(FirstCycle.SQUARE, 0), cycle.score]
	if is_instance_valid(cycle.mold_workbench):
		var mold := cycle.mold_workbench.carried_mold
		_stock.text += "\n\nMOLDE NAS MÃOS\n" + (str(MoldWorkbench.NAMES[mold]) if mold != &"" else "Nenhum")
	var seconds := ceili(cycle.time_left)
	_clock.text = "CICLO 1 • %02d:%02d\nEntregues: %d | Perdidos: %d" % [floori(seconds / 60.0), seconds % 60, cycle.delivered, cycle.missed]
	_patience.visible = cycle.order_item != null
	if cycle.order_item:
		var count: int = stock.get(cycle.order_item, 0)
		_order.text = "CLIENTE %02d • %ds\n%d × %s  (%d/%d)\n%s" % [cycle.customer_number, ceili(cycle.order_time_left), cycle.order_quantity, cycle.order_item.item_name, mini(count, cycle.order_quantity), cycle.order_quantity, "Pronto! Entregue no balcão." if count >= cycle.order_quantity else "Produza e colete as formas."]
		_patience.max_value = cycle.order_time_total
		_patience.value = cycle.order_time_left
		_patience.modulate = Color("ff7777") if cycle.order_time_left < 10.0 else Color("74ddc0")
	else:
		_order.text = "BALCÃO\nPróximo cliente chegando..." if cycle.running else "BALCÃO\nAtendimento encerrado"
	if not cycle.running:
		_overlay.show()
		if not _overlay.is_in_group("modal_repair_ui"):
			_overlay.add_to_group("modal_repair_ui")
		if cycle.finished:
			_intro.text = "PRIMEIRO EXPEDIENTE CONCLUÍDO\n\nPedidos entregues: %d\nPedidos não atendidos: %d\nPontuação: $%d\n\nTente novamente para melhorar seu resultado!" % [cycle.delivered, cycle.missed, cycle.score]
			_button.text = "Jogar novamente"
		else:
			_intro.text = "FANTÁSTICA FÁBRICA DE FORMAS\nPrimeiro expediente • %d minutos\n\nVá à bancada de moldes à esquerda das máquinas.\nPegue um molde triangular ou monte um molde de quadrado.\nCarregue-o até a máquina correspondente e use Mouse1 para inserir.\nA máquina consome o molde; aguarde e colete o produto na saída.\nLeve os produtos ao balcão para entregar.\n\nWASD: andar • Mouse1: interagir/arrastar • R: girar • Esc: cancelar.\nO tempo continua durante a montagem e o transporte."
			_intro.text = _intro.text % ceili(cycle.round_duration / 60.0)
			_button.text = "Abrir a loja"
	else:
		_overlay.hide()
		if _overlay.is_in_group("modal_repair_ui"):
			_overlay.remove_from_group("modal_repair_ui")
