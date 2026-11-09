extends Button
var piece_data: ShapePieceData

func _get_drag_data(_at_position: Vector2) -> Variant:
	if disabled or piece_data == null:
		return null
	var preview := ShapePiece.new()
	preview.definition = piece_data
	var holder := Control.new()
	holder.add_child(preview)
	set_drag_preview(holder)
	return {"shape_piece": piece_data}
