extends Resource
class_name ShapePieceData

## Geometry centered on the pivot. No machine rules.
@export var shape_id: StringName
@export var polygon: PackedVector2Array
@export var icon: Texture2D
@export var color: Color = Color(0.78, 0.55, 0.26)
@export_range(1.0, 180.0) var rotation_step_degrees: float = 90.0
@export var can_rotate: bool = true
## Optional mapping used only by the inventory adapter.
@export var inventory_item: ItemData

func is_valid() -> bool:
	return not shape_id.is_empty() and polygon.size() >= 3 and not Geometry2D.triangulate_polygon(polygon).is_empty()