extends Node
## Nearby interactable selection, interaction commands and prompt.
const Indicator = preload("res://entities/player/interaction_indicator.gd")
@onready var indicator: Indicator = $"../InteractionIndicator"
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
	# The old label remains hidden for existing preview callers.
	interaction_label.hide()
	if body.controls_blocked():
		indicator.set_kind(Indicator.Kind.NONE)
		return
	var hands = body.get_node_or_null("Hands")
	var transport: bool = hands != null and hands.enabled()
	var carrying: bool = transport and not hands.is_empty()
	if transport and not carrying and nearest_ground_item() != null:
		indicator.set_kind(Indicator.Kind.PICKUP)
		return
	current_interactable = nearest_station(carrying)
	indicator.set_kind(Indicator.Kind.INTERACT if _station_available(current_interactable) else Indicator.Kind.NONE)

func _station_available(station: Interactable) -> bool:
	if station == null:
		return false
	var host := station.get_parent()
	if host is MachineNode and host.manual_production:
		return host.manual_available and host.production_timer.is_stopped()
	if host is MoldWorkbench:
		return host.session_active
	if host is ShopNode and host.order_counter:
		var cycle = get_tree().get_first_node_in_group("first_cycle")
		return cycle != null and cycle.workshop_active()
	return true

func nearest_station(carrying: bool) -> Interactable:
	var nearest: Interactable
	var distance := INF
	var cycle = get_tree().get_first_node_in_group("first_cycle")
	for area in body.get_node("InteractionRange").get_overlapping_areas():
		if not area is Interactable or area.collision_layer == 0:
			continue
		var preparation_bench: bool = area.get_parent() is MoldWorkbench and cycle != null and cycle.preparing
		if carrying and not (area.get_parent() is MachineNode or area.get_parent() is ShopNode or preparation_bench):
			continue
		var ray := PhysicsRayQueryParameters2D.create(body.global_position, area.global_position, 1, [body.get_rid()])
		if not body.get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		var d: float = body.global_position.distance_squared_to(area.global_position)
		if d < distance:
			distance = d
			nearest = area
	return nearest
