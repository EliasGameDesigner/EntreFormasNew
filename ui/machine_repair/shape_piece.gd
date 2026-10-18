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
	if definition.full_shape_art and definition.icon:
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var bounds := Rect2(definition.polygon[0], Vector2.ZERO)
		for point in definition.polygon:
			bounds = bounds.expand(point)
		# Map the image onto the actual snap/hit polygon, including its diagonal.
		# Atlas UVs must refer to the source texture, not the cropped resource.
		var source: Texture2D = definition.icon
		var region := Rect2(Vector2.ZERO, source.get_size())
		if source is AtlasTexture:
			region = source.region
			source = source.atlas
		var uv := PackedVector2Array()
		for point in definition.polygon:
			uv.append((region.position + (point - bounds.position) / bounds.size * region.size) / source.get_size())
		draw_polygon(definition.polygon, PackedColorArray([Color.WHITE]), uv, source)
		return
	draw_colored_polygon(definition.polygon, definition.color)
	var outline := definition.polygon.duplicate()
	outline.append(outline[0])
	draw_polyline(outline, Color(1.0, 0.87, 0.55), 2.0, true)
	# Existing item artwork remains an emblem inside the exact silhouette.
	if definition.icon:
		draw_texture_rect(definition.icon, Rect2(-18, -18, 36, 36), false)
