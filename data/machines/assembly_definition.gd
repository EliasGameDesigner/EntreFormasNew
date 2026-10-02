extends Resource
class_name AssemblyDefinition

@export var title: String = "Montagem"
@export_multiline var instructions: String
@export var board_size: Vector2 = Vector2(680, 280)
@export var slots: Array[ShapeSlotData] = []

func is_valid() -> bool:
	var has_required := false
	for slot in slots:
		if slot == null or slot.piece == null or not slot.piece.is_valid():
			return false
		has_required = has_required or slot.required
	return has_required and board_size.x > 0.0 and board_size.y > 0.0