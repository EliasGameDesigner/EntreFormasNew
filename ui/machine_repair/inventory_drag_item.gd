extends Button
class_name InventoryDragItem

signal piece_requested(piece: ShapePieceData)
var piece_data: ShapePieceData

func setup(data: ShapePieceData, count: int) -> void:
	piece_data = data
	icon = data.icon
	expand_icon = true
	custom_minimum_size = Vector2(150, 65)
	text = "%s x%d" % [data.inventory_item.item_name, count]
	disabled = count <= 0
	tooltip_text = "Arraste até a mesa ou clique para retirar uma peça. Na mesa: Mouse1 arrasta, R gira."
	pressed.connect(func(): piece_requested.emit(piece_data))

func _get_drag_data(_at_position: Vector2) -> Variant:
	if disabled:
		return null
	var preview := TextureRect.new()
	preview.texture = piece_data.icon
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(48, 48)
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_drag_preview(preview)
	return {"shape_piece": piece_data}