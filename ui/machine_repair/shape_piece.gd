extends Node2D
class_name ShapePiece

var definition: ShapePieceData
var slot: ShapeSlot
var dragging: bool = false

func contains_point(board_position: Vector2) -> bool:
	return definition != null and Geometry2D.is_point_in_polygon(transform.affine_inverse() * board_position, definition.polygon)

func rotate_step() -> void:
	if definition.can_rotate:
		rotation_degrees += definition.rotation_step_degrees

func _draw() -> void:
	if definition == null:
		return
	draw_colored_polygon(definition.polygon, definition.color)
	var outline := definition.polygon.duplicate()
	outline.append(outline[0])
	draw_polyline(outline, Color(1.0, 0.87, 0.55), 2.0, true)
	# Existing item artwork remains an emblem inside the exact silhouette.
	if definition.icon:
		draw_texture_rect(definition.icon, Rect2(-18, -18, 36, 36), false)