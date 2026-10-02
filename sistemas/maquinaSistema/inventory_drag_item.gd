extends PanelContainer
class_name InventoryDragItem

signal item_clicked(item: ItemData)

var item_data: ItemData = null
var quantity: int = 0

var normal_style: StyleBoxFlat
var hover_style: StyleBoxFlat

var _mouse_press_pos: Vector2 = Vector2.ZERO
var _is_mouse_pressed: bool = false

@onready var icon_rect: TextureRect = $VBoxContainer/CenterContainer/IconRect
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var quantity_label: Label = $VBoxContainer/QuantityLabel

func _ready() -> void:
	custom_minimum_size = Vector2(90, 100)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_setup_styles()
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_setup_child_mouse_filters()
	update_display()

func _setup_child_mouse_filters() -> void:
	# Garante que nenhum nó filho capture cliques ou impeça o início do drag
	for child in find_children("*", "Control", true, false):
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _setup_styles() -> void:
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.15, 0.18, 0.25, 0.9)
	normal_style.border_width_bottom = 2
	normal_style.border_width_top = 2
	normal_style.border_width_left = 2
	normal_style.border_width_right = 2
	normal_style.border_color = Color(0.3, 0.35, 0.45, 0.8)
	normal_style.corner_radius_bottom_left = 6
	normal_style.corner_radius_bottom_right = 6
	normal_style.corner_radius_top_left = 6
	normal_style.corner_radius_top_right = 6

	hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(0.22, 0.28, 0.38, 0.95)
	hover_style.border_color = Color(0.4, 0.75, 1.0, 1.0)

func setup(item: ItemData, count: int) -> void:
	item_data = item
	quantity = count
	update_display()

func update_display() -> void:
	if not is_inside_tree():
		return
		
	if item_data != null:
		add_theme_stylebox_override("panel", normal_style)
		icon_rect.texture = item_data.icon
		icon_rect.modulate = Color(1.0, 1.0, 1.0, 1.0)
		name_label.text = item_data.item_name
		quantity_label.text = "x" + str(quantity)
		tooltip_text = "Arraste esta peça até a mesa de montagem ou clique para encaixar (" + item_data.item_name + ")"
	else:
		icon_rect.texture = null
		name_label.text = ""
		quantity_label.text = ""
		tooltip_text = ""

func _on_mouse_entered() -> void:
	if item_data != null and quantity > 0:
		add_theme_stylebox_override("panel", hover_style)

func _on_mouse_exited() -> void:
	add_theme_stylebox_override("panel", normal_style)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_data == null or quantity <= 0:
		return null

	_is_mouse_pressed = false # Drag em andamento

	# Cria a prévia visual que segue o mouse
	var preview_root = Control.new()
	preview_root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var preview_panel = PanelContainer.new()
	preview_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var preview_style = StyleBoxFlat.new()
	preview_style.bg_color = Color(0.1, 0.15, 0.28, 0.92)
	preview_style.border_width_bottom = 2
	preview_style.border_width_top = 2
	preview_style.border_width_left = 2
	preview_style.border_width_right = 2
	preview_style.border_color = Color(0.3, 0.85, 1.0, 1.0)
	preview_style.corner_radius_bottom_left = 8
	preview_style.corner_radius_bottom_right = 8
	preview_style.corner_radius_top_left = 8
	preview_style.corner_radius_top_right = 8
	preview_panel.add_theme_stylebox_override("panel", preview_style)

	var vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)

	var icon = TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = item_data.icon
	icon.custom_minimum_size = Vector2(48, 48)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(icon)

	var lbl = Label.new()
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.text = item_data.item_name
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.modulate = Color(1.0, 0.9, 0.4)
	vbox.add_child(lbl)

	preview_panel.add_child(vbox)
	# Posiciona de forma que não interfira no cursor
	preview_panel.position = -Vector2(32, 32)
	preview_root.add_child(preview_panel)

	set_drag_preview(preview_root)

	return {
		"type": "inventory_item",
		"item_data": item_data,
		"source": self
	}

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_is_mouse_pressed = true
			_mouse_press_pos = event.global_position
			# Não consome aqui para permitir ao Godot verificar o limiar de arrasto
		else:
			if _is_mouse_pressed:
				_is_mouse_pressed = false
				# Se o mouse foi solto no mesmo lugar (não arrastou), considera um clique simples
				if event.global_position.distance_to(_mouse_press_pos) < 10.0:
					if item_data != null and quantity > 0:
						item_clicked.emit(item_data)
						accept_event()
