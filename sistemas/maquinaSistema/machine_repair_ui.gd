extends CanvasLayer
class_name MachineRepairUI

# Referência da máquina atual que está sendo consertada/montada
var current_machine: Node2D = null

# SFX para feedback tátil de encaixe e conclusão
const SFX_SNAP = preload("res://Audios/litupsubway-key-collect-sfx-522219.mp3")

const ShapeAssemblyBoard = preload("res://sistemas/maquinaSistema/shape_assembly_board.gd")

# Referências de nós na árvore de cena
@onready var control_root: Control = $Control
@onready var dim_bg: ColorRect = $Control/DimBackground
@onready var main_panel: PanelContainer = $Control/MainPanel
@onready var machine_title_label: Label = $Control/MainPanel/MarginContainer/VBoxContainer/Header/TitleLabel
@onready var close_button: Button = $Control/MainPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var formula_label: Label = $Control/MainPanel/MarginContainer/VBoxContainer/BlueprintContainer/FormulaLabel
@onready var assembly_board: ShapeAssemblyBoard = $Control/MainPanel/MarginContainer/VBoxContainer/BlueprintContainer/AssemblyBoardCenter/ShapeAssemblyBoard
@onready var status_label: Label = $Control/MainPanel/MarginContainer/VBoxContainer/ActionContainer/StatusLabel
@onready var cost_label: Label = $Control/MainPanel/MarginContainer/VBoxContainer/ActionContainer/CostLabel
@onready var repair_button: Button = $Control/MainPanel/MarginContainer/VBoxContainer/ActionContainer/RepairButton

# Inventário Horizontal Inferior
@onready var bottom_panel: PanelContainer = $Control/BottomInventoryPanel
@onready var inventory_items_container: HBoxContainer = $Control/BottomInventoryPanel/MarginContainer/VBoxContainer/ScrollContainer/InventoryHBox
@onready var empty_inventory_label: Label = $Control/BottomInventoryPanel/MarginContainer/VBoxContainer/ScrollContainer/EmptyLabel

func _ready() -> void:
	# Oculta o menu ao iniciar o jogo
	hide()
	
	# Conexões de botões
	close_button.pressed.connect(close_ui)
	repair_button.pressed.connect(_on_repair_button_pressed)
	
	# Conexões da Mesa de Montagem Geométrica
	if assembly_board:
		assembly_board.piece_slotted.connect(_on_board_piece_slotted)
		assembly_board.piece_unslotted.connect(_on_board_piece_unslotted)
		assembly_board.board_changed.connect(_update_repair_status)
	
	# Estilização inicial
	_setup_panel_styles()

func _setup_panel_styles() -> void:
	# Estilo do painel principal (Workbench de conserto)
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.1, 0.15, 0.95)
	panel_style.border_width_bottom = 3
	panel_style.border_width_top = 3
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_color = Color(0.85, 0.65, 0.3, 0.95) # Dourado / Bronze
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.shadow_size = 12
	panel_style.shadow_color = Color(0, 0, 0, 0.7)
	main_panel.add_theme_stylebox_override("panel", panel_style)

	# Estilo do painel de inventário inferior
	var bottom_style = StyleBoxFlat.new()
	bottom_style.bg_color = Color(0.07, 0.09, 0.14, 0.95)
	bottom_style.border_width_bottom = 2
	bottom_style.border_width_top = 2
	bottom_style.border_width_left = 2
	bottom_style.border_width_right = 2
	bottom_style.border_color = Color(0.35, 0.6, 0.85, 0.9) # Azul técnico
	bottom_style.corner_radius_bottom_left = 10
	bottom_style.corner_radius_bottom_right = 10
	bottom_style.corner_radius_top_left = 10
	bottom_style.corner_radius_top_right = 10
	bottom_style.shadow_size = 8
	bottom_style.shadow_color = Color(0, 0, 0, 0.6)
	bottom_panel.add_theme_stylebox_override("panel", bottom_style)

func open_ui(machine: Node2D) -> void:
	if current_machine == machine and visible:
		return
		
	current_machine = machine
	
	if not InventoryManager.inventory_changed.is_connected(_refresh_horizontal_inventory):
		InventoryManager.inventory_changed.connect(_refresh_horizontal_inventory)
		
	_configure_assembly_board_for_machine()
	_populate_machine_info()
	_refresh_horizontal_inventory()
	_update_repair_status()
	
	show()

func close_ui() -> void:
	# Devolve qualquer item alocado na mesa de volta ao inventário
	_refund_slotted_items()
	
	if InventoryManager.inventory_changed.is_connected(_refresh_horizontal_inventory):
		InventoryManager.inventory_changed.disconnect(_refresh_horizontal_inventory)
		
	current_machine = null
	hide()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
			close_ui()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_E or event.physical_keycode == KEY_E:
			close_ui()
			get_viewport().set_input_as_handled()

func _configure_assembly_board_for_machine() -> void:
	if current_machine == null or current_machine.machine_data == null or assembly_board == null:
		return
		
	var data: MachineData = current_machine.machine_data
	var name_lower = data.machine_name.to_lower()
	
	if "quadrado" in name_lower:
		assembly_board.setup_square(data.required_items)
	elif "retangulo" in name_lower or "retângulo" in name_lower:
		assembly_board.setup_rectangle(data.required_items)
	elif "triangulo" in name_lower or "triângulo" in name_lower:
		assembly_board.setup_triangle(data.required_items)
	else:
		assembly_board.setup_generic(data.required_items)

func _populate_machine_info() -> void:
	if current_machine == null or current_machine.machine_data == null:
		return
		
	var data: MachineData = current_machine.machine_data
	machine_title_label.text = "🔧 MONTAGEM GEOMÉTRICA: " + data.machine_name.to_upper()
	formula_label.text = _get_pedagogical_formula_text(data)

func _get_pedagogical_formula_text(data: MachineData) -> String:
	var name_lower = data.machine_name.to_lower()
	if "quadrado" in name_lower:
		return "📐 Geometria Plana: Quadrado | Área = L²\n🧩 Desafio de Montagem: Arraste 2 Triângulos para os encaixes e monte o Quadrado!"
	elif "retangulo" in name_lower or "retângulo" in name_lower:
		return "📐 Geometria Plana: Retângulo | Área = Base × Altura (A = B × H)\n🧩 Desafio de Montagem: Arraste 2 Quadrados para os encaixes e monte o Retângulo!"
	elif "triangulo" in name_lower or "triângulo" in name_lower:
		return "📐 Geometria Plana: Triângulo | Área = (Base × Altura) / 2\n⭐ Máquina Geradora Primária pronta para calibrar e produzir!"
	else:
		return "📐 Matriz de Montagem Mecânica\n🧩 Arraste as peças necessárias para montar a forma e ativar a máquina."

func _refresh_horizontal_inventory() -> void:
	for child in inventory_items_container.get_children():
		child.queue_free()
		
	var all_items = InventoryManager.get_all_items()
	
	if all_items.is_empty():
		empty_inventory_label.show()
		return
	else:
		empty_inventory_label.hide()
		
	for item in all_items:
		var qty = all_items[item]
		if qty > 0:
			var card = _instantiate_inventory_drag_item(item, qty)
			inventory_items_container.add_child(card)

func _instantiate_inventory_drag_item(item: ItemData, count: int) -> InventoryDragItem:
	var drag_item = InventoryDragItem.new()
	drag_item.name = "InvItem_" + item.item_name
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	
	var center = CenterContainer.new()
	center.name = "CenterContainer"
	var icon = TextureRect.new()
	icon.name = "IconRect"
	icon.custom_minimum_size = Vector2(44, 44)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	center.add_child(icon)
	vbox.add_child(center)
	
	var name_lbl = Label.new()
	name_lbl.name = "NameLabel"
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 11)
	vbox.add_child(name_lbl)
	
	var qty_lbl = Label.new()
	qty_lbl.name = "QuantityLabel"
	qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qty_lbl.add_theme_font_size_override("font_size", 11)
	qty_lbl.modulate = Color(1.0, 0.85, 0.3)
	vbox.add_child(qty_lbl)
	
	drag_item.add_child(vbox)
	drag_item.item_clicked.connect(_on_inventory_item_clicked)
	drag_item.setup(item, count)
	return drag_item

func _on_inventory_item_clicked(item: ItemData) -> void:
	if assembly_board == null:
		return
	var free_slot = assembly_board.find_first_free_slot(item)
	if free_slot >= 0:
		assembly_board.slot_item(free_slot, item)

func _on_board_piece_slotted(_slot_index: int, item: ItemData) -> void:
	# Debita 1 unidade do inventário
	if InventoryManager.remove_item(item, 1):
		AudioManager.play_sfx(SFX_SNAP)
		_update_repair_status()
		_refresh_horizontal_inventory()

func _on_board_piece_unslotted(_slot_index: int, item: ItemData) -> void:
	# Devolve a peça para o inventário
	InventoryManager.add_item(item, 1)
	AudioManager.play_sfx(SFX_SNAP)
	_update_repair_status()
	_refresh_horizontal_inventory()

func _refund_slotted_items() -> void:
	if assembly_board == null:
		return
	for slot_idx in assembly_board.slotted_items:
		var item: ItemData = assembly_board.slotted_items[slot_idx]
		if item != null:
			InventoryManager.add_item(item, 1)
	assembly_board.slotted_items.clear()
	assembly_board.queue_redraw()

func _update_repair_status() -> void:
	if current_machine == null or current_machine.machine_data == null or assembly_board == null:
		return
		
	var data: MachineData = current_machine.machine_data
	var total_required_slots = assembly_board.get_total_slots()
	var filled_slots = assembly_board.get_filled_count()
	var is_complete = assembly_board.is_fully_assembled()
	var has_enough_money = (InventoryManager.money >= data.repair_cash_cost)
	
	# Texto de status pedagógico e progresso
	var name_lower = data.machine_name.to_lower()
	if is_complete:
		if "quadrado" in name_lower:
			status_label.text = "✨ Quadrado Completo! (2 Triângulos unidos formam L²)"
		elif "retangulo" in name_lower or "retângulo" in name_lower:
			status_label.text = "✨ Retângulo Completo! (2 Quadrados unidos formam Base × Altura)"
		else:
			status_label.text = "✨ Forma Montada com Sucesso! (%d / %d)" % [filled_slots, total_required_slots]
		status_label.modulate = Color(0.3, 1.0, 0.4)
	else:
		if total_required_slots == 0:
			status_label.text = "Pronta para ativação operacional."
			status_label.modulate = Color(0.3, 1.0, 0.4)
		else:
			status_label.text = "Peças Encaixadas: %d / %d (Arraste as peças até a mesa)" % [filled_slots, total_required_slots]
			status_label.modulate = Color(1.0, 0.8, 0.4)
		
	# Texto de custo financeiro (se houver)
	if data.repair_cash_cost > 0:
		cost_label.text = "Custo Adicional: $%d  (Seu Saldo: $%d)" % [data.repair_cash_cost, InventoryManager.money]
		if has_enough_money:
			cost_label.modulate = Color(0.8, 0.9, 1.0)
		else:
			cost_label.modulate = Color(1.0, 0.35, 0.35)
		cost_label.show()
	else:
		cost_label.hide()
		
	# Habilitação do botão de conserto
	if is_complete and has_enough_money:
		repair_button.disabled = false
		repair_button.text = "✨ ATIVAR E CONSERTAR MÁQUINA ✨"
		repair_button.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		repair_button.disabled = true
		if not is_complete:
			repair_button.text = "Encaixe as peças para montar a forma..."
		else:
			repair_button.text = "Saldo insuficiente ($%d)" % data.repair_cash_cost
		repair_button.modulate = Color(0.7, 0.7, 0.7, 0.8)

func _on_repair_button_pressed() -> void:
	if current_machine == null or current_machine.machine_data == null or assembly_board == null:
		return
		
	var data: MachineData = current_machine.machine_data
	
	# Validação final de peças e saldo
	if not assembly_board.is_fully_assembled():
		GameUI.show_notification("Encaixe todas as peças necessárias primeiro!")
		return
		
	if InventoryManager.money < data.repair_cash_cost:
		GameUI.show_notification("Saldo insuficiente para pagar o custo de reparo!")
		return
		
	# Consome dinheiro se houver
	if data.repair_cash_cost > 0:
		InventoryManager.money -= data.repair_cash_cost
		
	# As peças já foram retiradas do inventário durante o encaixe
	assembly_board.slotted_items.clear()
	
	# Executa o conserto na máquina
	current_machine.repair_machine()
	AudioManager.play_sfx(SFX_SNAP)
	
	# Fecha o menu
	close_ui()
