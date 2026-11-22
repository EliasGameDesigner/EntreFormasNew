extends PanelContainer
## Counter ledger. Quantities always reflect deposited products, never held items.
const ITEMS = [FirstCycle.TRIANGLE, FirstCycle.SQUARE, FirstCycle.RECTANGLE, FirstCycle.PARALLELOGRAM, FirstCycle.TRAPEZOID]
const SHAPES = [&"triangle", &"square", &"rectangle", &"parallelogram", &"trapezoid"]
var rows: Dictionary = {}
var counts: Dictionary = {}
var money: Label
var held_icon: TextureRect
var held_text: Label

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(224, 416)
	var paper := StyleBoxTexture.new()
	paper.texture = preload("res://assets/textures/ui/counter_notebook_v1.png")
	paper.set_content_margin(SIDE_LEFT, 34)
	paper.set_content_margin(SIDE_RIGHT, 26)
	paper.set_content_margin(SIDE_TOP, 28)
	paper.set_content_margin(SIDE_BOTTOM, 26)
	add_theme_stylebox_override("panel", paper)
	var column := VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 4)
	add_child(column)
	var title := _label(column, "BALCÃO", 25)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label(column, "Peças para entrega", 17).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_separator(column)
	for item in ITEMS:
		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_theme_constant_override("separation", 18)
		column.add_child(row)
		var icon := _icon(row)
		icon.texture = item.icon
		var count := _label(row, "× 0", 25)
		count.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rows[item] = row
		counts[item] = count
	# Reserve the writing area even before all products become available.
	var space := Control.new()
	space.mouse_filter = Control.MOUSE_FILTER_IGNORE
	space.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(space)
	_separator(column)
	money = _label(column, "Moedas: 0", 22)
	_separator(column)
	_label(column, "NAS MÃOS", 17)
	var held := HBoxContainer.new()
	held.mouse_filter = Control.MOUSE_FILTER_IGNORE
	held.add_theme_constant_override("separation", 8)
	column.add_child(held)
	held_icon = _icon(held)
	held_text = _label(held, "Vazias", 18)
	held_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	held_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func refresh(cycle: FirstCycle) -> void:
	var stock := cycle.counter_stock if cycle.physical_transport else InventoryManager.get_all_items()
	for i in ITEMS.size():
		rows[ITEMS[i]].visible = i < mini(cycle.cycle_number + 1, ITEMS.size())
		counts[ITEMS[i]].text = "× %d" % stock.get(ITEMS[i], 0)
	money.text = "Moedas: %d" % cycle.score
	held_icon.texture = null
	held_text.text = "Vazias"
	var hands = get_tree().get_first_node_in_group("player_hands")
	if hands != null and hands.product != null:
		held_icon.texture = hands.product.icon
		held_text.text = "Peça\n" + hands.product.item_name
	elif is_instance_valid(cycle.mold_workbench):
		var mold := cycle.mold_workbench.carried_mold
		if mold in SHAPES:
			held_icon.texture = load("res://data/items/%s_mold_texture.tres" % mold)
			held_text.text = "Molde\n" + str(MoldWorkbench.NAMES[mold])
	held_icon.visible = held_icon.texture != null

func _icon(parent: Control) -> TextureRect:
	var icon := TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.custom_minimum_size = Vector2(36, 36)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	parent.add_child(icon)
	return icon

func _label(parent: Control, text: String, font_size: int) -> Label:
	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("38291d"))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	parent.add_child(label)
	return label

func _separator(parent: Control) -> void:
	var line := ColorRect.new()
	line.color = Color("84633a55")
	line.custom_minimum_size.y = 1
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(line)
