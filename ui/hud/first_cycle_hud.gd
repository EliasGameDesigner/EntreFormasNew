extends CanvasLayer

@export var cycle: FirstCycle
var _order: Label
var _stock: Label
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
	controls.text = "WASD: mover • Mouse1: pegar/largar/inserir/depositar • Duplo clique: girar • F11: tela cheia"
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
	_restart_button = Button.new()
	_restart_button.text = "Recomeçar do ciclo 1"
	box.add_child(_restart_button)
	_restart_button.pressed.connect(_restart)
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
	var stock := InventoryManager.get_all_items()
	if cycle.physical_transport:
		stock = cycle.counter_stock
	_stock.text = "PRODUTOS\nTriângulos: %d\nQuadrados: %d\nMoedas: $%d" % [stock.get(FirstCycle.TRIANGLE, 0), stock.get(FirstCycle.SQUARE, 0), cycle.score]
	if is_instance_valid(cycle.mold_workbench):
		var mold := cycle.mold_workbench.carried_mold
		_stock.text += "\n\nMOLDE NAS MÃOS\n" + (str(MoldWorkbench.NAMES[mold]) if mold != &"" else "Nenhum")
	if cycle.physical_transport:
		var hands = get_tree().get_first_node_in_group("player_hands")
		var held := "Nada"
		if hands != null and hands.product != null:
			held = "Peça: " + hands.product.item_name
		elif cycle.mold_workbench.carried_mold != &"":
			held = "Molde: " + str(MoldWorkbench.NAMES[cycle.mold_workbench.carried_mold])
		_stock.text = "NO BALCÃO\nTriângulos: %d\nQuadrados: %d\nMoedas: $%d\n\nNAS MÃOS\n%s" % [stock.get(FirstCycle.TRIANGLE, 0), stock.get(FirstCycle.SQUARE, 0), cycle.score, held]
	var seconds := ceili(cycle.time_left)
	_clock.text = "CICLO %d • %02d:%02d\nEntregues: %d | Perdidos: %d" % [cycle.cycle_number, floori(seconds / 60.0), seconds % 60, cycle.delivered, cycle.missed]
	if cycle.cycle_number >= 2:
		_stock.text = _stock.text.replace("\nMoedas:", "\nRetângulos: %d\nMoedas:" % stock.get(FirstCycle.RECTANGLE, 0))
	if cycle.cycle_number >= 3:
		_stock.text = _stock.text.replace("\nMoedas:", "\nParalelogramos: %d\nMoedas:" % stock.get(FirstCycle.PARALLELOGRAM, 0))
	if cycle.cycle_number >= 4:
		_stock.text = _stock.text.replace("\nMoedas:", "\nTrapézios: %d\nMoedas:" % stock.get(FirstCycle.TRAPEZOID, 0))
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
	if not cycle.running:
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
			_intro.text = "FANTÁSTICA FÁBRICA DE FORMAS\nPrimeiro expediente • %d minutos\n\nVá à bancada de moldes à esquerda das máquinas.\nPegue um molde triangular ou monte um molde de quadrado.\nCarregue-o até a máquina correspondente e use Mouse1 para inserir.\nA máquina consome o molde; aguarde e colete o produto na saída.\nLeve os produtos ao balcão para entregar.\n\nWASD: andar • Mouse1: interagir/arrastar • Duplo clique: girar • Esc: cancelar.\nO tempo continua durante a montagem e o transporte."
			_intro.text = _intro.text % ceili(cycle.round_duration / 60.0)
			if cycle.physical_transport:
				_intro.text = "FANTÁSTICA FÁBRICA DE FORMAS\nPrimeiro expediente • %d minutos\n\nPrepare um molde na bancada e carregue até a máquina.\nMouse1 perto da máquina: inserir o molde.\nMouse1 perto da peça no chão: pegar.\nMouse1 carregando, longe das estações: largar.\nVocê só pode carregar UM objeto por vez.\nMouse1 no balcão: depositar a peça na pilha.\nO pedido é entregue automaticamente quando estiver completo.\nPeças depositadas permanecem se o cliente desistir.\n\nWASD: andar • Duplo clique: girar na montagem • Esc: cancelar montagem." % ceili(cycle.round_duration / 60.0)
			_button.text = "Abrir a loja"
	else:
		_overlay.hide()
		if _overlay.is_in_group("modal_repair_ui"):
			_overlay.remove_from_group("modal_repair_ui")
