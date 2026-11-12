extends ShapeAssemblyBoard
## Recipes recognize relative geometry anywhere on the table; guides are optional.
signal mold_assembled(shape: StringName)
var free_mode := true
var available_shapes: Array[StringName] = []
var hint: AssemblyDefinition

func try_snap(piece: ShapePiece) -> bool:
	if not free_mode:
		return super.try_snap(piece)
	if not pieces.has(piece):
		return false
	for shape in MoldWorkbench.RECIPES:
		if not available_shapes.has(shape):
			continue
		var recipe: AssemblyDefinition = MoldWorkbench.RECIPES[shape]
		if pieces.size() < recipe.slots.size():
			continue
		for anchor_index in range(recipe.slots.size()):
			var anchor = recipe.slots[anchor_index]
			for quarter in range(4):
				var angle := quarter * PI / 2.0
				if not _matches(piece, anchor, angle):
					continue
				var origin: Vector2 = piece.position - anchor.target_position.rotated(angle)
				var selected: Array[ShapePiece] = [piece]
				if _match_remaining(recipe, 0, anchor_index, origin, angle, selected):
					for component in selected:
						_remove_piece(component)
					mold_assembled.emit(shape)
					board_changed.emit()
					return true
	return false

## Match every slot to a distinct piece, with the released piece as an anchor.
func _match_remaining(recipe: AssemblyDefinition, index: int, anchor_index: int, origin: Vector2, angle: float, selected: Array[ShapePiece]) -> bool:
	if index == recipe.slots.size():
		return true
	if index == anchor_index:
		return _match_remaining(recipe, index + 1, anchor_index, origin, angle, selected)
	var entry = recipe.slots[index]
	var target: Vector2 = origin + entry.target_position.rotated(angle)
	for candidate in pieces:
		if selected.has(candidate) or candidate.position.distance_to(target) > 20.0 or not _matches(candidate, entry, angle):
			continue
		selected.append(candidate)
		if _match_remaining(recipe, index + 1, anchor_index, origin, angle, selected):
			return true
		selected.pop_back()
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
