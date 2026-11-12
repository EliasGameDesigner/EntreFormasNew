extends ShapeAssemblyBoard
## Recipes recognize relative geometry anywhere on the table; guides are optional.
signal mold_assembled(shape: StringName)
var free_mode := true
var available_shapes: Array[StringName] = []
var hint: AssemblyDefinition

func try_snap(piece: ShapePiece) -> bool:
	if not free_mode:
		return super.try_snap(piece)
	for shape in MoldWorkbench.RECIPES:
		if not available_shapes.has(shape):
			continue
		var recipe: AssemblyDefinition = MoldWorkbench.RECIPES[shape]
		for other in pieces:
			if other == piece:
				continue
			for quarter in range(4):
				var angle := quarter * PI / 2.0
				var a = recipe.slots[0]
				var b = recipe.slots[1]
				if not _matches(piece, a, angle) or not _matches(other, b, angle):
					continue
				var offset: Vector2 = (b.target_position - a.target_position).rotated(angle)
				if (other.position - piece.position).distance_to(offset) <= 20.0:
					_remove_piece(other)
					_remove_piece(piece)
					mold_assembled.emit(shape)
					board_changed.emit()
					return true
	return false

func _matches(piece: ShapePiece, entry: Resource, angle: float) -> bool:
	if piece.definition.shape_id != entry.piece.shape_id:
		return false
	for point in piece.definition.polygon:
		var rotated := point.rotated(piece.rotation)
		var found := false
		for target in entry.piece.polygon:
			if rotated.distance_to(target.rotated(deg_to_rad(entry.target_rotation_degrees) + angle)) < 1.0:
				found = true
				break
		if not found:
			return false
	return true

func _remove_piece(piece: ShapePiece) -> void:
	pieces.erase(piece)
	if dragged_piece == piece:
		dragged_piece = null
	remove_child(piece)
	piece.queue_free()

func set_hint(recipe: AssemblyDefinition) -> void:
	hint = recipe
	queue_redraw()

func _draw() -> void:
	super._draw()
	if not free_mode or hint == null:
		return
	var offset := size / 2.0 - hint.board_size / 2.0
	for entry in hint.slots:
		var outline := PackedVector2Array()
		for point in entry.piece.polygon:
			outline.append(point.rotated(deg_to_rad(entry.target_rotation_degrees)) + entry.target_position + offset)
		draw_colored_polygon(outline, Color(0.9, 0.8, 0.5, 0.12))
		outline.append(outline[0])
		draw_polyline(outline, Color("e4cb8b"), 2.0, true)
