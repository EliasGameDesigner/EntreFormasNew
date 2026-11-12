extends Node
## Nearby interactable selection, interaction commands and prompt.
@onready var body: CharacterBody2D = get_parent()
@onready var interaction_label: Label = $"../InteractionLabel"
var current_interactable: Interactable = null

func _ready() -> void:
	interaction_label.text = "[Mouse 1] Interagir"
	interaction_label.hide()

func handle_input(event: InputEvent) -> void:
	var hands = body.get_node_or_null("Hands")
	if hands != null and hands.enabled():
		if event.is_action_pressed("interact") and not event.is_echo():
			if hands.is_empty():
				var nearest := nearest_ground_item()
				if nearest != null and hands.take(nearest):
					get_viewport().set_input_as_handled()
					return
			current_interactable = nearest_station(not hands.is_empty())
			if not hands.is_empty() and current_interactable == null:
				hands.drop()
				get_viewport().set_input_as_handled()
				return
	if not is_instance_valid(current_interactable):
		return
	if event.is_action_pressed("interact") and not event.is_echo():
		current_interactable.start_interaction(body)
		get_viewport().set_input_as_handled()
	elif event.is_action_released("interact"):
		current_interactable.stop_interaction()

func _on_area_entered(area: Area2D) -> void:
	if area is Interactable:
		current_interactable = area
		interaction_label.show()

func _on_area_exited(area: Area2D) -> void:
	if area == current_interactable:
		if current_interactable.is_being_interacted:
			current_interactable.stop_interaction()
		current_interactable = null
		interaction_label.hide()

func nearest_ground_item() -> Node2D:
	var nearest: Node2D
	var distance := INF
	for item in get_tree().get_nodes_in_group("ground_carryables"):
		if not item.can_be_picked_by(body):
			continue
		var d: float = body.global_position.distance_to(item.global_position)
		if d <= distance:
			distance = d
			nearest = item
	return nearest

func refresh_prompt() -> void:
	var hands = body.get_node_or_null("Hands")
	if hands == null or not hands.enabled():
		return
	if not hands.is_empty():
		var station := nearest_station(true)
		interaction_label.text = "Mouse1: largar"
		if station != null:
			interaction_label.text = "Mouse1: depositar no balcão" if station.get_parent() is ShopNode else "Mouse1: inserir na máquina"
		interaction_label.show()
	elif nearest_ground_item() != null:
		interaction_label.text = "Mouse1: pegar"
		interaction_label.show()
	else:
		interaction_label.text = "Mouse1: interagir"
		interaction_label.visible = is_instance_valid(current_interactable)

func nearest_station(carrying: bool) -> Interactable:
	var nearest: Interactable
	var distance := INF
	for area in body.get_node("InteractionRange").get_overlapping_areas():
		if not area is Interactable or area.collision_layer == 0:
			continue
		if carrying and not (area.get_parent() is MachineNode or area.get_parent() is ShopNode):
			continue
		var ray := PhysicsRayQueryParameters2D.create(body.global_position, area.global_position, 1, [body.get_rid()])
		if not body.get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		var d: float = body.global_position.distance_squared_to(area.global_position)
		if d < distance:
			distance = d
			nearest = area
	return nearest
