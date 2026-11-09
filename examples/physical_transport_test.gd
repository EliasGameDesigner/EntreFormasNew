extends Node2D
var checks := 0
var failures := 0
var room: Node2D
var player
var hands
var cycle: FirstCycle

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func action(name: StringName) -> void:
	var event := InputEventAction.new()
	event.action = name
	event.pressed = true
	player._unhandled_input(event)
	event.pressed = false
	player._unhandled_input(event)

func near(point: Vector2) -> void:
	player.global_position = point
	await get_tree().physics_frame
	await get_tree().physics_frame

func ground() -> Array:
	return get_tree().get_nodes_in_group("ground_carryables").filter(func(item): return not item._collected and not item.is_queued_for_deletion())

func spawn_product(item: ItemData) -> PhysicalItem:
	var dropped = preload("res://entities/resources/physical_item.tscn").instantiate()
	dropped.item_data = item
	dropped.position = player.position + Vector2(20, 0)
	room.add_child(dropped)
	return dropped

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	room.get_node("HUD")._restart()
	cycle = room.get_node("FirstCycle")
	cycle.set_process(false)
	player = room.get_node("CharacterBody2D")
	player.set_physics_process(false)
	hands = player.get_node("Hands")
	var bench := cycle.mold_workbench
	var reach_test := spawn_product(FirstCycle.TRIANGLE)
	reach_test.position = player.position + Vector2(82, 0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(reach_test.can_be_picked_by(player), "pickup sensor reaches beyond the old 80-pixel cutoff")
	check(player.interaction.nearest_ground_item() == reach_test, "prompt and pickup use the same sensor")
	action(&"interact")
	check(hands.product == FirstCycle.TRIANGLE, "Mouse1 collects from pickup sensor before physical contact")
	hands.clear()
	await get_tree().process_frame
	var out_of_reach := spawn_product(FirstCycle.TRIANGLE)
	out_of_reach.position = player.position + Vector2(140, 0)
	check(not hands.take(out_of_reach), "sensor rejects distant items")
	out_of_reach.position = Vector2(2206, -1400)
	await near(Vector2(2140, -1400))
	check(not out_of_reach.can_be_picked_by(player), "pickup sensor cannot collect through partition")
	out_of_reach.queue_free()
	await get_tree().process_frame
	await near(Vector2(1552, -1072))
	var pushed := spawn_product(FirstCycle.TRIANGLE)
	pushed.position = player.position + Vector2(55, 0)
	var start_x := pushed.position.x
	player.set_physics_process(true)
	Input.action_press("right")
	await get_tree().create_timer(0.5).timeout
	Input.action_release("right")
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO
	check(pushed.position.x > start_x + 10, "walking into a ground item pushes it")
	await get_tree().create_timer(0.6).timeout
	check(pushed.linear_velocity.length() < 5, "pushed item slows to rest")
	await near(pushed.position + Vector2(0, 55))
	action(&"interact")
	check(hands.product == FirstCycle.TRIANGLE, "pushed object remains pickable")
	hands.clear()
	await get_tree().process_frame
	await near(Vector2(1552, -1072))
	player.animation.update_animation(Vector2.DOWN)
	check(cycle.physical_transport, "physical transport enabled by default")
	check(bench.begin_mold(&"triangle"), "take initial mold")
	action(&"interact")
	check(hands.is_empty() and ground().size() == 1, "Mouse1 drops mold and frees hands")
	check(ground()[0].mold_shape == &"triangle", "dropped item preserves mold identity")
	check(ground()[0] is RigidBody2D and not ground()[0].freeze, "molds also have active ground physics")
	ground()[0]._on_body_entered(player)
	check(hands.is_empty(), "no automatic pickup")
	action(&"interact")
	check(bench.carried_mold == &"triangle", "Mouse1 picks up mold")
	var spare := spawn_product(FirstCycle.SQUARE)
	check(not hands.take(spare), "cannot hold product and mold together")
	check(not cycle.square_machine.request_manual_production(), "wrong machine rejects mold")
	check(bench.carried_mold == &"triangle", "wrong machine preserves mold")
	spare.queue_free()
	await near(cycle.triangle_machine.global_position + Vector2(0, 65))
	cycle.triangle_machine.production_time = 0.05
	action(&"interact")
	check(hands.is_empty(), "same Mouse1 inserts mold in nearby machine")
	await get_tree().create_timer(0.15).timeout
	check(ground().size() == 1, "machine leaves product on floor")
	var produced = ground()[0]
	await near(produced.global_position + Vector2(0, 55))
	check(InventoryManager.get_all_items().get(FirstCycle.TRIANGLE, 0) == 0, "walking over product does not add inventory")
	action(&"interact")
	check(hands.product == FirstCycle.TRIANGLE, "Mouse1 picks produced item into hands")
	check(not bench.begin_mold(&"triangle"), "workbench refuses occupied hands")
	player.animation.update_animation(Vector2.DOWN)
	player.animation.update_animation(Vector2.ZERO)
	check(player.get_node("CarriedMold").visible, "produced item rendered in hands")
	await near(Vector2(1552, -1072))
	action(&"interact")
	check(hands.is_empty(), "Mouse1 drops produced piece")
	action(&"interact")
	check(hands.product == FirstCycle.TRIANGLE, "dropped product can be recovered")
	var counter = room.get_node("shop_node")
	await near(counter.global_position + Vector2(0, 65))
	action(&"interact")
	check(hands.is_empty() and cycle.counter_stock.get(FirstCycle.TRIANGLE, 0) == 1, "Mouse1 deposits one item")
	check(cycle.delivered == 0, "partial pile does not complete order")
	var extra := spawn_product(FirstCycle.TRIANGLE)
	check(hands.take(extra), "second product carried")
	action(&"interact")
	check(cycle.delivered == 1 and cycle.counter_stock[FirstCycle.TRIANGLE] == 0, "complete order consumes exactly deposited quantity")
	check(cycle.deposit_product(FirstCycle.SQUARE), "can stock counter between customers")
	cycle.deposit_product(FirstCycle.SQUARE)
	cycle.advance_time(cycle.arrival_delay + 0.1)
	cycle.advance_time(2.1)
	check(cycle.delivered == 2, "next matching order uses stored stack")
	cycle.deposit_product(FirstCycle.TRIANGLE)
	cycle._spawn_order()
	cycle.order_quantity = 5
	cycle.advance_time(cycle.order_time_left + 0.1)
	check(cycle.counter_stock[FirstCycle.TRIANGLE] == 1, "expired order preserves deposited pieces")
	check(bench.begin_mold(&"triangle"), "can take mold with stocked counter")
	action(&"interact")
	check(bench.carried_mold == &"triangle", "counter refuses molds without consuming them")
	var modal := Node.new()
	modal.add_to_group("modal_repair_ui")
	add_child(modal)
	action(&"interact")
	check(bench.carried_mold == &"triangle", "modal blocks dropping")
	modal.queue_free()
	await get_tree().process_frame
	await near(Vector2(2650, -1400))
	player.animation.update_animation(Vector2.RIGHT)
	action(&"interact")
	check(bench.carried_mold == &"triangle", "cannot drop an object inside the wall")
	await near(Vector2(1552, -1072))
	player.animation.update_animation(Vector2.DOWN)
	action(&"interact")
	cycle.finish_round()
	room.get_node("HUD")._restart()
	cycle.set_process(false)
	check(hands.is_empty() and ground().is_empty() and cycle.counter_stock.is_empty(), "restart clears hands floor and counter")
	bench.carried_mold = &"square"
	bench.changed.emit()
	action(&"interact")
	check(ground().size() == 1 and ground()[0].mold_shape == &"square", "square mold remains a mold on the floor")
	action(&"interact")
	check(bench.carried_mold == &"square" and hands.product == null, "square mold recovered without becoming product")
	bench.carried_mold = &""
	bench.changed.emit()
	# Render a representative partial order with two separate vertical piles.
	await near(counter.global_position + Vector2(0, 65))
	cycle.order_quantity = 6
	for i in range(3):
		cycle.deposit_product(FirstCycle.TRIANGLE)
	for i in range(2):
		cycle.deposit_product(FirstCycle.SQUARE)
	var held := spawn_product(FirstCycle.TRIANGLE)
	hands.take(held)
	player.animation.update_animation(Vector2.DOWN)
	player.animation.update_animation(Vector2.ZERO)
	var camera: Camera2D = player.get_node("FollowCamera")
	camera.position_smoothing_enabled = false
	camera.force_update_scroll()
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 720))
		GameUI.notification_label.hide()
		player.interaction.interaction_label.hide()
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/physical_transport.png")
	print("PHYSICAL TRANSPORT: %d checks, %d failures" % [checks, failures])
	await get_tree().process_frame
	get_tree().quit(1 if failures else 0)
