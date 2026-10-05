extends Resource
class_name ProductionRecipe

## One entry per unit consumed, independently of the repair puzzle.
@export var materials: Array[ItemData] = []

func get_requirements() -> Dictionary:
	var counts: Dictionary = {}
	for item in materials:
		if item == null:
			return {}
		counts[item] = counts.get(item, 0) + 1
	return counts

func is_valid() -> bool:
	return not materials.is_empty() and not materials.has(null)
