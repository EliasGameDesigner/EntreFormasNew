extends Resource
class_name ShapeSlotData

@export var piece: ShapePieceData
@export var target_position: Vector2
@export_range(-360.0, 360.0) var target_rotation_degrees: float = 0.0
@export_range(0.0, 100.0) var position_tolerance: float = 22.0
@export_range(0.0, 180.0) var rotation_tolerance_degrees: float = 12.0
@export var required: bool = true
@export var allow_removal: bool = true
@export var spawn_position: Vector2
@export_range(-360.0, 360.0) var spawn_rotation_degrees: float = 0.0