extends Node2D
class_name ShapeSlot

var definition: ShapeSlotData
var occupant: ShapePiece

func matches(piece: ShapePiece) -> bool:
	# Canonical Resource identity also prevents same-name pieces with different geometry.
	if piece.definition != definition.piece:
		return false
	var angle_error := absf(wrapf(piece.rotation - rotation, -PI, PI))
	return piece.position.distance_to(position) <= definition.position_tolerance and angle_error <= deg_to_rad(definition.rotation_tolerance_degrees)

func accepts(piece: ShapePiece) -> bool:
	return occupant == null and matches(piece)

func _draw() -> void:
	if definition == null or definition.piece == null:
		return
	var polygon := definition.piece.polygon
	draw_colored_polygon(polygon, Color(0.12, 0.24, 0.35, 0.85))
	var outline := polygon.duplicate()
	outline.append(outline[0])
	draw_polyline(outline, Color(0.42, 0.74, 0.91), 2.0, true)