extends Control
class_name ShapeAssemblyBoard

signal assembly_completed
signal board_changed
signal piece_snapped
## The host decides how to supply a piece; no inventory access here.
signal supply_requested(piece: ShapePieceData, at_position: Vector2)

@export var definition: AssemblyDefinition
@export var populate_on_ready: bool = true
var slots: Array[ShapeSlot] = []
var pieces: Array[ShapePiece] = []
var completed: bool = false
var dragged_piece: ShapePiece
var _grab_offset := Vector2.ZERO
var _drag_origin := Vector2.ZERO
var _drag_rotation: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if definition:
		setup(definition, populate_on_ready)

func clear() -> void:
	dragged_piece = null
	for child in pieces + slots:
		remove_child(child)
		child.queue_free()
	pieces.clear()
	slots.clear()
	completed = false
	definition = null

func setup(recipe: AssemblyDefinition, supply_pieces: bool = true) -> bool:
	clear()
	if recipe == null or not recipe.is_valid():
		return false
	definition = recipe
	custom_minimum_size = recipe.board_size
	for entry in recipe.slots:
		var slot := ShapeSlot.new()
		slot.definition = entry
		slot.position = entry.target_position
		slot.rotation_degrees = entry.target_rotation_degrees
		add_child(slot)
		slots.append(slot)
	if supply_pieces:
		for entry in recipe.slots:
			add_piece(entry.piece, entry.spawn_position, entry.spawn_rotation_degrees)
	queue_redraw()
	board_changed.emit()
	return true

func add_piece(data: ShapePieceData, at_position: Vector2, angle: float = 0.0) -> ShapePiece:
	if completed or data == null or not data.is_valid():
		return null
	var piece := ShapePiece.new()
	piece.definition = data
	piece.position = at_position
	piece.rotation_degrees = angle
	piece.z_index = 1
	add_child(piece)
	pieces.append(piece)
	return piece

func begin_drag(piece: ShapePiece, at_position: Vector2) -> bool:
	if completed or dragged_piece != null or not pieces.has(piece):
		return false
	if piece.slot:
		if not piece.slot.definition.allow_removal:
			return false
		piece.slot.occupant = null
		piece.slot = null
	dragged_piece = piece
	_drag_origin = piece.position
	_drag_rotation = piece.rotation
	_grab_offset = piece.position - at_position
	piece.dragging = true
	piece.z_index = 2
	move_child(piece, -1)
	board_changed.emit()
	return true

func move_drag(at_position: Vector2) -> void:
	if dragged_piece:
		dragged_piece.position = at_position + _grab_offset

func rotate_drag() -> void:
	if dragged_piece:
		dragged_piece.rotate_step()

func end_drag(at_position: Vector2) -> void:
	if dragged_piece == null:
		return
	move_drag(at_position)
	var piece := dragged_piece
	dragged_piece = null
	piece.dragging = false
	piece.z_index = 1
	if not Rect2(Vector2.ZERO, size).has_point(piece.position):
		piece.position = _drag_origin
		piece.rotation = _drag_rotation
	try_snap(piece)

func try_snap(piece: ShapePiece) -> bool:
	if completed or not pieces.has(piece) or piece.slot != null:
		return false
	var nearest: ShapeSlot
	var distance := INF
	for slot in slots:
		var candidate_distance := slot.position.distance_to(piece.position)
		if slot.accepts(piece) and candidate_distance < distance:
			nearest = slot
			distance = candidate_distance
	if nearest == null:
		return false
	piece.position = nearest.position
	piece.rotation = nearest.rotation
	piece.slot = nearest
	nearest.occupant = piece
	piece_snapped.emit()
	board_changed.emit()
	if is_fully_assembled():
		completed = true
		assembly_completed.emit()
	return true

func is_fully_assembled() -> bool:
	if definition == null or not definition.is_valid():
		return false
	for slot in slots:
		if slot.definition.required and (not is_instance_valid(slot.occupant) or not slot.matches(slot.occupant)):
			return false
	return true

func get_filled_count() -> int:
	var count := 0
	for slot in slots:
		if slot.definition.required and is_instance_valid(slot.occupant) and slot.matches(slot.occupant):
			count += 1
	return count

func get_required_count() -> int:
	var count := 0
	for slot in slots:
		if slot.definition.required:
			count += 1
	return count

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var children := get_children()
		children.reverse()
		for child in children:
			if child is ShapePiece and child.contains_point(event.position):
				begin_drag(child, event.position)
				accept_event()
				break

func _input(event: InputEvent) -> void:
	if dragged_piece == null or not is_visible_in_tree():
		return
	if event is InputEventMouseMotion:
		move_drag(get_global_transform_with_canvas().affine_inverse() * event.position)
	elif event.is_action_pressed("rotate_piece"):
		rotate_drag()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		end_drag(get_global_transform_with_canvas().affine_inverse() * event.position)
	else:
		return
	get_viewport().set_input_as_handled()

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return not completed and data is Dictionary and data.get("shape_piece") is ShapePieceData

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(at_position, data):
		supply_requested.emit(data["shape_piece"], at_position)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and dragged_piece:
		end_drag(_drag_origin - _grab_offset)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.08, 0.13))
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.3, 0.5, 0.65), false, 2.0)