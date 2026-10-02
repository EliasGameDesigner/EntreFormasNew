extends PanelContainer
class_name RepairSlot

signal item_slotted(slot_index: int, item: ItemData)
signal item_unslotted(slot_index: int, item: ItemData)

@export var required_item: ItemData = null
var slotted_item: ItemData = null
var slot_index: int = 0
var is_drag_hovered: bool = false

var normal_style: StyleBoxFlat
var hover_valid_style: StyleBoxFlat
var hover_invalid_style: StyleBoxFlat
var filled_style: StyleBoxFlat

@onready var icon_rect: TextureRect = $VBoxContainer/CenterContainer/IconRect
@onready var status_label: Label = $VBoxContainer/StatusLabel
@onready var name_label: Label = $VBoxContainer/NameLabel

func _ready() -> void:
	custom_minimum_size = Vector2(130, 150)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_setup_styles()
	update_display()

func _setup_styles() -> void:
	# Normal empty style
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.12, 0.14, 0.2, 0.85)
	normal_style.border_width_bottom = 2
	normal_style.border_width_top = 2
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_color = Color(0.35, 0.4, 0.55, 0.8)
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8

	# Hover valid (Green glow)
	hover_valid_style = normal_style.duplicate()
	hover_valid_style.bg_color = Color(0.1, 0.25, 0.15, 0.95)
	hover_valid_style.border_color = Color(0.2, 0.85, 0.4, 1.0)
	hover_valid_style.border_width_bottom = 3
	hover_valid_style.border_width_top = 3
	hover_valid_style.border_width_left = 3
	hover_valid_style.border_width_right = 3

	# Hover invalid (Red glow)
	hover_invalid_style = normal_style.duplicate()
	hover_invalid_style.bg_color = Color(0.25, 0.1, 0.1, 0.95)
	hover_invalid_style.border_color = Color(0.9, 0.25, 0.25, 1.0)

	# Filled style (Cyan/Gold accent)
	filled_style = normal_style.duplicate()
	filled_style.bg_color = Color(0.14, 0.22, 0.28, 0.95)
	filled_style.border_color = Color(0.9, 0.7, 0.2, 1.0)
	filled_style.border_width_bottom = 3
	filled_style.border_width_top = 3
	filled_style.border_width_left = 3
	filled_style.border_width_right = 3

func setup(req_item: ItemData, idx: int) -> void:
	required_item = req_item
	slot_index = idx
	slotted_item = null
	update_display()

func update_display() -> void:
	if not is_inside_tree():
		return
		
	if slotted_item != null:
		add_theme_stylebox_override("panel", filled_style)
		icon_rect.texture = slotted_item.icon
		icon_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
		name_label.text = slotted_item.item_name
		status_label.text = "[ Encaixado! ]"
		status_label.modulate = Color(0.4, 1.0, 0.5)
		tooltip_text = "Clique para remover a peça " + slotted_item.item_name
	else:
		if is_drag_hovered:
			add_theme_stylebox_override("panel", hover_valid_style)
		else:
			add_theme_stylebox_override("panel", normal_style)
			
		if required_item != null:
			icon_rect.texture = required_item.icon
			icon_rect.modulate = Color(1.0, 1.0, 1.0, 0.35) # Ghost silhouette
			name_label.text = required_item.item_name
			status_label.text = "Slot Vazio"
			status_label.modulate = Color(0.7, 0.75, 0.85)
			tooltip_text = "Arraste um(a) " + required_item.item_name + " para este slot"
		else:
			icon_rect.texture = null
			name_label.text = "Qualquer Peça"
			status_label.text = "Slot Vazio"
			status_label.modulate = Color(0.7, 0.75, 0.85)
			tooltip_text = "Arraste uma peça aqui"

func slot_piece(item: ItemData) -> bool:
	if slotted_item != null:
		return false
	if required_item != null and item != required_item:
		return false
		
	slotted_item = item
	update_display()
	item_slotted.emit(slot_index, item)
	return true

func unslot_piece() -> ItemData:
	if slotted_item == null:
		return null
	var removed = slotted_item
	slotted_item = null
	update_display()
	item_unslotted.emit(slot_index, removed)
	return removed

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if slotted_item != null:
		return false
	if not (data is Dictionary and data.get("type") == "inventory_item"):
		return false
	var incoming_item: ItemData = data.get("item_data")
	if incoming_item == null:
		return false
	if required_item != null and incoming_item != required_item:
		return false
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var incoming_item: ItemData = data.get("item_data")
	if incoming_item:
		slot_piece(incoming_item)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if slotted_item != null:
			unslot_piece()
			accept_event()
