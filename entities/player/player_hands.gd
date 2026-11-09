extends Node
## One carried object: workbench mold OR produced item, never both.
signal changed
var product: ItemData

func _ready() -> void:
	add_to_group("player_hands")

func bench() -> MoldWorkbench:
	return get_tree().get_first_node_in_group("mold_workbench") as MoldWorkbench

func enabled() -> bool:
	var cycle = get_tree().get_first_node_in_group("first_cycle")
	return cycle != null and cycle.physical_transport and cycle.running

func is_empty() -> bool:
	return product == null and (bench() == null or bench().carried_mold == &"")

func take(item: Node2D) -> bool:
	if not enabled() or not is_empty() or not item.can_be_picked_by(get_parent()):
		return false
	if item.mold_shape != &"":
		bench().carried_mold = item.mold_shape
		bench().changed.emit()
	else:
		product = item.item_data
	item._collected = true
	item.queue_free()
	changed.emit()
	return true

func clear() -> void:
	product = null
	changed.emit()

func drop() -> bool:
	if not enabled() or is_empty():
		return false
	var body = get_parent()
	var point: Vector2 = body.global_position + body.animation.facing * 54
	var ray := PhysicsRayQueryParameters2D.create(body.global_position, point, 1, [body.get_rid()])
	if not body.get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
		GameUI.show_notification("Sem espaço para largar nessa direção.")
		return false
	var item = load("res://entities/resources/physical_item.tscn").instantiate()
	var footprint := CircleShape2D.new()
	footprint.radius = 15.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = footprint
	query.transform = Transform2D(0, point)
	query.collision_mask = 3
	query.exclude = [body.get_rid()]
	if not body.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
		item.free()
		GameUI.show_notification("Sem espaço para largar nessa direção.")
		return false
	item.item_data = product if product != null else MoldWorkbench.PRODUCTS[bench().carried_mold]
	item.mold_shape = bench().carried_mold if product == null else &""
	item.position = body.get_parent().to_local(point)
	body.get_parent().add_child(item)
	product = null
	bench().carried_mold = &""
	bench().changed.emit()
	changed.emit()
	return true
