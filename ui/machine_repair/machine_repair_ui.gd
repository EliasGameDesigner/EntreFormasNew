extends CanvasLayer
class_name MachineRepairUI

signal repair_completed
const SFX_SNAP = preload("res://assets/audio/sfx/litupsubway-key-collect-sfx-522219.mp3")
var current_machine: MachineNode
## Items are reserved when supplied, refunded on cancel, consumed only on success.
var _reserved: Dictionary = {}
var _finishing: bool = false

@onready var machine_title_label: Label = $Control/MainPanel/MarginContainer/VBoxContainer/Header/TitleLabel
@onready var close_button: Button = $Control/MainPanel/MarginContainer/VBoxContainer/Header/CloseButton
@onready var formula_label: Label = $Control/MainPanel/MarginContainer/VBoxContainer/BlueprintContainer/FormulaLabel
@onready var assembly_board: ShapeAssemblyBoard = $Control/MainPanel/MarginContainer/VBoxContainer/BlueprintContainer/AssemblyBoardCenter/ShapeAssemblyBoard
@onready var status_label: Label = $Control/MainPanel/MarginContainer/VBoxContainer/ActionContainer/StatusLabel
@onready var cost_label: Label = $Control/MainPanel/MarginContainer/VBoxContainer/ActionContainer/CostLabel
@onready var inventory_items_container: HBoxContainer = $Control/BottomInventoryPanel/MarginContainer/VBoxContainer/ScrollContainer/InventoryHBox
@onready var empty_inventory_label: Label = $Control/BottomInventoryPanel/MarginContainer/VBoxContainer/ScrollContainer/EmptyLabel

func _ready() -> void:
	hide()
	_setup_panel_styles()
	close_button.pressed.connect(close_ui)
	assembly_board.supply_requested.connect(_supply_piece)
	assembly_board.board_changed.connect(_update_status)
	assembly_board.piece_snapped.connect(func(): AudioManager.play_sfx(SFX_SNAP))
	assembly_board.assembly_completed.connect(_on_assembly_completed)
	InventoryManager.inventory_changed.connect(_refresh_inventory)
	InventoryManager.money_changed.connect(_on_money_changed)

func open_ui(machine: MachineNode) -> void:
	if visible or machine.machine_data == null or not machine.machine_data.can_break:
		return
	if machine.current_state != MachineNode.MachineState.BROKEN:
		return
	var recipe := machine.machine_data.repair_assembly
	if recipe == null or not recipe.is_valid():
		GameUI.show_notification("Esta máquina não possui uma montagem válida.")
		return
	for slot in recipe.slots:
		if slot.piece.inventory_item == null:
			GameUI.show_notification("Configure o item de inventário das peças desta máquina.")
			return
	current_machine = machine
	_finishing = false
	assembly_board.setup(recipe, false)
	machine_title_label.text = machine.machine_data.machine_name
	formula_label.text = recipe.instructions + "\nMouse1: arrastar | R: girar enquanto segura | Esc: cancelar"
	add_to_group("modal_repair_ui")
	show()
	_refresh_inventory()
	_update_status()

func close_ui() -> void:
	if not visible and current_machine == null:
		return
	_finishing = true
	hide()
	remove_from_group("modal_repair_ui")
	current_machine = null
	_refund_reserved()
	assembly_board.clear()
	_finishing = false

func _exit_tree() -> void:
	_refund_reserved()

func _refund_reserved() -> void:
	var items := _reserved.values()
	_reserved.clear()
	for item in items:
		InventoryManager.add_item(item)

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_ui()
		get_viewport().set_input_as_handled()

func _refresh_inventory() -> void:
	if not visible or _finishing or assembly_board.definition == null:
		return
	for child in inventory_items_container.get_children():
		inventory_items_container.remove_child(child)
		child.queue_free()
	var definitions: Array[ShapePieceData] = []
	for slot in assembly_board.definition.slots:
		if not definitions.has(slot.piece):
			definitions.append(slot.piece)
	var available := InventoryManager.get_all_items()
	var total := 0
	for data in definitions:
		var count: int = available.get(data.inventory_item, 0)
		if count <= 0:
			continue
		var card := InventoryDragItem.new()
		card.name = "Piece_" + String(data.shape_id)
		card.setup(data, count)
		card.piece_requested.connect(_supply_from_tray)
		inventory_items_container.add_child(card)
		total += 1
	empty_inventory_label.visible = total == 0

func _supply_from_tray(data: ShapePieceData) -> void:
	if assembly_board.definition == null:
		return
	var supplied := 0
	for piece in assembly_board.pieces:
		if piece.definition == data:
			supplied += 1
	for slot in assembly_board.definition.slots:
		if slot.piece == data:
			if supplied == 0:
				_supply_piece(data, slot.spawn_position, slot.spawn_rotation_degrees)
				return
			supplied -= 1

func _supply_piece(data: ShapePieceData, at_position: Vector2, angle: float = 0.0) -> void:
	if not visible or _finishing or assembly_board.completed:
		return
	var needed := 0
	for slot in assembly_board.definition.slots:
		if slot.piece == data:
			needed += 1
	for piece in assembly_board.pieces:
		if piece.definition == data:
			needed -= 1
	if needed <= 0 or not InventoryManager.remove_item(data.inventory_item):
		return
	var piece := assembly_board.add_piece(data, at_position, angle)
	if piece == null:
		InventoryManager.add_item(data.inventory_item)
		return
	_reserved[piece] = data.inventory_item
	# A tray drop keeps its actual position and orientation; no fallback slot.
	assembly_board.try_snap(piece)

func _update_status() -> void:
	if not is_instance_valid(current_machine) or _finishing:
		return
	status_label.text = "Encaixes: %d / %d" % [assembly_board.get_filled_count(), assembly_board.get_required_count()]
	var cost := current_machine.machine_data.repair_cash_cost
	cost_label.text = "Custo: $%d | Saldo: $%d" % [cost, InventoryManager.money]
	cost_label.visible = cost > 0
	if assembly_board.completed and InventoryManager.money < cost:
		status_label.text = "Montagem concluída. Aguardando saldo para o conserto."

func _on_money_changed(_amount: int) -> void:
	_update_status()
	if visible and assembly_board.completed:
		_on_assembly_completed()

func _on_assembly_completed() -> void:
	# Finish outside input/signal traversal: closing removes board children.
	_finish_repair.call_deferred()

func _finish_repair() -> void:
	if _finishing or not visible or not is_instance_valid(current_machine):
		return
	if current_machine.current_state != MachineNode.MachineState.BROKEN:
		close_ui()
		return
	if not assembly_board.is_fully_assembled():
		return
	var cost := current_machine.machine_data.repair_cash_cost
	if InventoryManager.money < cost:
		_update_status()
		return
	_finishing = true
	InventoryManager.money -= cost
	for piece in _reserved.keys():
		if is_instance_valid(piece) and piece.slot != null:
			_reserved.erase(piece)
	repair_completed.emit()
	close_ui()

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
	$Control/MainPanel.add_theme_stylebox_override("panel", panel_style)

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
	$Control/BottomInventoryPanel.add_theme_stylebox_override("panel", bottom_style)
