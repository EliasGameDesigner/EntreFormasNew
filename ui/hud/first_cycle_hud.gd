extends CanvasLayer

@export var cycle: FirstCycle
var _order: Label
var _stock: PanelContainer
var _clock: Label
var _patience: ProgressBar
var _overlay: ColorRect
var _intro: Label
var _button: Button
var _restart_button: Button
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
	root.theme = preload("res://ui/machine_repair/workbench_theme.gd").create()
	_stock = preload("res://ui/hud/counter_notebook.gd").new()
	root.add_child(_stock)
	_stock.position = Vector2(12, 16)
	_stock_panel = _stock
	_order_panel = _panel(root, Control.PRESET_TOP_RIGHT, -188, -16)
	_clock_panel = _panel(root, Control.PRESET_CENTER_TOP, -190, 190)
	_clock = _label(_clock_panel, 28)
	_clock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var order_column := VBoxContainer.new()
	_order_panel.add_child(order_column)
	_order = _label(order_column, 16)
	_order.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_patience = ProgressBar.new()
	_patience.custom_minimum_size = Vector2(0, 12)
	_patience.show_percentage = false
	order_column.add_child(_patience)
	_overlay = ColorRect.new()
	_overlay.color = Color(0.06, 0.045, 0.03, 0.94)
	root.add_child(_overlay)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	_overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 24)
	center.add_child(box)
	_intro = _label(box, 28)
	_intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button = Button.new()
	_button.custom_minimum_size.y = 52
	box.add_child(_button)
	_button.pressed.connect(_enter_workshop)
	_restart_button = Button.new()
	_restart_button.text = "Recomeçar do ciclo 1"
	box.add_child(_restart_button)
	_restart_button.pressed.connect(_enter_workshop)
	cycle.changed.connect(_refresh)
	var hands = get_tree().get_first_node_in_group("player_hands")
	if hands != null:
		hands.changed.connect(_refresh)
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
	panel.offset_bottom = 112
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxTexture.new()
	var plaque := AtlasTexture.new()
	plaque.atlas = preload("res://assets/textures/ui/shift_plaque_v1.png")
	plaque.region = Rect2(18, 118, 2140, 484)
	style.texture = plaque
	style.set_content_margin_all(20)
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

func _enter_workshop() -> void:
	cycle.prepare_session()

func _start() -> void:
	_overlay.hide()
	if _overlay.is_in_group("modal_repair_ui"):
		_overlay.remove_from_group("modal_repair_ui")
	if cycle.has_next_cycle():
		cycle.start_next_cycle()
	else:
		cycle.start_round()

func _restart() -> void:
	_overlay.hide()
	if _overlay.is_in_group("modal_repair_ui"):
		_overlay.remove_from_group("modal_repair_ui")
	cycle.start_round()

func _refresh() -> void:
	if not is_instance_valid(_order):
		return
	_order_panel.visible = get_tree().get_first_node_in_group("customer_order_bubble") == null
	var stock := InventoryManager.get_all_items()
	if cycle.physical_transport:
		stock = cycle.counter_stock
	_stock.refresh(cycle)
	var seconds := ceili(cycle.time_left)
	_clock.text = "CICLO %d   |   %02d:%02d\nEntregues: %d   Perdidos: %d" % [cycle.cycle_number, floori(seconds / 60.0), seconds % 60, cycle.delivered, cycle.missed]
	if cycle.preparing:
		_clock.text = "PREPARAÇÃO | CICLO %d\nInicie no balcão de atendimento" % cycle.pending_cycle_number()
		_button.text = "Iniciar ciclo %d no balcão" % cycle.pending_cycle_number()
		if cycle.initial_tutorial_pending():
			_clock.text = "COMECE O TUTORIAL\nVá ao balcão marcado à direita"
	_patience.visible = cycle.order_item != null
	if cycle.order_item:
		var count: int = stock.get(cycle.order_item, 0)
		_order.text = "CLIENTE %02d • %ds\n%d × %s  (%d/%d)\n%s" % [cycle.customer_number, ceili(cycle.order_time_left), cycle.order_quantity, cycle.order_item.item_name, mini(count, cycle.order_quantity), cycle.order_quantity, "Pronto! Entregue no balcão." if count >= cycle.order_quantity else "Produza e colete as formas."]
		_patience.max_value = cycle.order_time_total
		if cycle.physical_transport:
			_order.text = "CLIENTE %02d • %ds\n%d × %s (%d/%d no balcão)\nLeve uma peça por vez." % [cycle.customer_number, ceili(cycle.order_time_left), cycle.order_quantity, cycle.order_item.item_name, mini(count, cycle.order_quantity), cycle.order_quantity]
		_patience.value = cycle.order_time_left
		_patience.modulate = Color("ff7777") if cycle.order_time_left < 10.0 else Color("74ddc0")
	else:
		_order.text = "BALCÃO\nPróximo cliente chegando..." if cycle.running else "BALCÃO\nAtendimento encerrado"
	if not cycle.running and not cycle.preparing:
		_restart_button.visible = cycle.has_next_cycle()
		_overlay.show()
		if not _overlay.is_in_group("modal_repair_ui"):
			_overlay.add_to_group("modal_repair_ui")
		if cycle.finished:
			_intro.text = "CICLO %d CONCLUÍDO\n\nTotal de pedidos entregues: %d\nTotal de pedidos não atendidos: %d\nPontuação acumulada: $%d" % [cycle.cycle_number, cycle.delivered, cycle.missed, cycle.score]
			if cycle.has_next_cycle():
				_intro.text += "\n\nPRÓXIMO: RETÂNGULOS\nMonte dois moldes quadrados e una-os na bancada.\nA máquina de retângulos será liberada no mesmo mapa.\nMantenha suas peças e pilhas do balcão para o próximo ciclo."
				if cycle.cycle_number == 2:
					_intro.text = _intro.text.left(_intro.text.find("\n\nPRÓXIMO:")) + "\n\nPRÓXIMO: PARALELOGRAMOS\nUna dois triângulos pelas laterais na bancada.\nA nova máquina será liberada no mesmo mapa.\nSeu estoque e moldes continuam disponíveis."
				if cycle.cycle_number == 3:
					_intro.text = _intro.text.left(_intro.text.find("\n\nPRÓXIMO:")) + "\n\nPRÓXIMO: TRAPÉZIOS\nUna um quadrado e dois triângulos na bancada.\nA máquina de trapézios será liberada no mesmo mapa.\nSeu estoque e moldes continuam disponíveis."
				_button.text = "Continuar para o ciclo %d" % (cycle.cycle_number + 1)
			else:
				_intro.text += "\n\nOs quatro ciclos foram concluídos!"
				_button.text = "Recomeçar do ciclo 1"
		else:
			_intro.text = "FANTÁSTICA FÁBRICA DE FORMAS\n\nArt, a cartola, será seu instrutor no primeiro ciclo.\n\nWASD: andar • Botão esquerdo: interagir\nVá ao balcão marcado e inicie o tutorial com Art.\nArt ensinará o restante enquanto você joga."
			_button.text = "Entrar na fábrica"
	else:
		_overlay.hide()
		if _overlay.is_in_group("modal_repair_ui"):
			_overlay.remove_from_group("modal_repair_ui")
