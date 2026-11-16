extends CanvasLayer
## Persistent, non-interactive order bubble following the customer in screen space.
@export var cycle: FirstCycle
@export var customer: Sprite2D
var panel: PanelContainer
var icon: TextureRect
var quantity: Label
var progress: Label
var patience: ProgressBar
var location: Label
var tail: Polygon2D
var pinned := false

func _ready() -> void:
	layer = 45
	process_priority = 100
	add_to_group("customer_order_bubble")
	var root := Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tail = Polygon2D.new()
	tail.color = Color("ad8950")
	root.add_child(tail)
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(176, 0)
	root.add_child(panel)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("f0dfb7")
	style.border_color = Color("ad8950")
	style.set_border_width_all(3)
	style.set_corner_radius_all(10)
	style.set_content_margin_all(10)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 4
	panel.add_theme_stylebox_override("panel", style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	panel.add_child(column)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	column.add_child(row)
	icon = TextureRect.new()
	icon.custom_minimum_size = Vector2(44, 44)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	row.add_child(icon)
	quantity = _label(row, 24)
	progress = _label(column, 12)
	patience = ProgressBar.new()
	patience.custom_minimum_size = Vector2(0, 7)
	patience.show_percentage = false
	column.add_child(patience)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("6b5942")
	track.set_corner_radius_all(3)
	patience.add_theme_stylebox_override("background", track)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("477a65")
	fill.set_corner_radius_all(3)
	patience.add_theme_stylebox_override("fill", fill)
	location = _label(column, 11)
	_pass_through(root)
	cycle.changed.connect(_refresh)
	cycle.customer_changed.connect(_refresh)
	_refresh()

func _label(parent: Node, font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("32271f"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	parent.add_child(label)
	return label

func _pass_through(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_pass_through(child)

func _refresh() -> void:
	visible = cycle.running and cycle.order_item != null
	if not visible:
		return
	icon.texture = cycle.order_item.icon
	quantity.text = "× %d" % cycle.order_quantity
	var stock := cycle.counter_stock if cycle.physical_transport else InventoryManager.get_all_items()
	progress.text = "%d/%d no balcão • %ds" % [mini(int(stock.get(cycle.order_item, 0)), cycle.order_quantity), cycle.order_quantity, ceili(cycle.order_time_left)]
	patience.max_value = cycle.order_time_total
	patience.value = cycle.order_time_left
	patience.modulate = Color("ff9a86") if cycle.order_time_left < 10 else Color.WHITE

func _process(_delta: float) -> void:
	if not visible or customer.texture == null:
		return
	var head := customer.get_global_transform_with_canvas() * Vector2(0, -customer.texture.get_height() / 2.0)
	var screen := get_viewport().get_visible_rect()
	pinned = not screen.has_point(head)
	location.visible = pinned
	if pinned:
		var arrow := "→" if head.x > screen.end.x else "←"
		if head.x >= 0 and head.x <= screen.end.x:
			arrow = "↑" if head.y < 0 else "↓"
		location.text = "Cliente " + arrow
	panel.size = panel.get_combined_minimum_size()
	# Keep clear of the stock card, top clock and bottom controls when offscreen.
	var minimum := Vector2(minf(208, screen.size.x / 3), 116)
	var maximum := screen.size - panel.size - Vector2(12, 44)
	maximum = maximum.max(minimum)
	var desired := head - Vector2(panel.size.x / 2, panel.size.y + 14)
	panel.position = desired.clamp(minimum, maximum).round()
	tail.visible = not pinned
	var base := panel.position + Vector2(panel.size.x / 2, panel.size.y - 2)
	var tip := Vector2(clampf(head.x, base.x - 20, base.x + 20), base.y + 13)
	tail.polygon = PackedVector2Array([base + Vector2(-10, 0), tip, base + Vector2(10, 0)])
