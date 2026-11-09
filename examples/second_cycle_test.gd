extends Node2D
var checks := 0
var failures := 0
var player

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func click() -> void:
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	player._unhandled_input(event)
	event.pressed = false
	player._unhandled_input(event)

func near(point: Vector2) -> void:
	player.position = point
	await get_tree().physics_frame
	await get_tree().physics_frame

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	var room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	var cycle: FirstCycle = room.get_node("FirstCycle")
	var hud = room.get_node("HUD")
	player = room.get_node("CharacterBody2D")
	player.set_physics_process(false)
	var hands = player.get_node("Hands")
	var bench := cycle.mold_workbench
	var machine := cycle.rectangle_machine
	hud._start()
	cycle.set_process(false)
	check(cycle.cycle_number == 1 and not machine.manual_available, "rectangle machine locked in cycle one")
	check(not bench.available_shapes.has(&"rectangle"), "rectangle mold locked initially")
	check(not cycle.start_next_cycle(), "cannot skip a running cycle")
	cycle.deposit_product(FirstCycle.SQUARE)
	check(bench.begin_mold(&"triangle"), "take a mold before transition")
	var loose = preload("res://entities/resources/physical_item.tscn").instantiate()
	loose.item_data = FirstCycle.TRIANGLE
	loose.position = Vector2(1500, -1100)
	room.add_child(loose)
	cycle.advance_time(cycle.time_left)
	check(cycle.has_next_cycle() and not cycle.running, "timer leads to intermission")
	check(hud._button.text.contains("ciclo 2"), "intermission offers next cycle")
	hud._start()
	cycle.set_process(false)
	check(cycle.cycle_number == 2 and cycle.time_left == 240, "second cycle starts with its own duration")
	check(cycle.counter_stock.get(FirstCycle.SQUARE, 0) == 1, "counter stock survives transition")
	check(is_instance_valid(loose) and not loose.is_queued_for_deletion(), "ground objects survive transition")
	check(bench.carried_mold == &"triangle", "held mold survives intermission")
	check(machine.manual_available and machine.interactable.collision_layer != 0, "rectangle machine unlocks physically")
	check(machine.modulate == Color.WHITE and bench.available_shapes.has(&"rectangle"), "machine visual and workbench unlock")
	check(cycle.order_item == FirstCycle.RECTANGLE and cycle.order_quantity == 1, "first cycle-two customer requests one rectangle")
	check(hud._clock.text.contains("CICLO 2") and hud._stock.text.contains("Retângulos"), "HUD shows second cycle and rectangle stock")
	check(player.movement.speed == 210, "slightly faster walking")
	await near(Vector2(1552, -1072))
	player.animation.update_animation(Vector2.DOWN)
	click()
	check(hands.is_empty(), "drop previous mold using same action")
	check(bench.open_workbench() and bench.begin_mold(&"rectangle"), "start unlocked rectangle mold")
	check(bench.steps == [&"square", &"square", &"rectangle"], "assemble two square molds then a rectangle")
	while not bench.steps.is_empty():
		var board: ShapeAssemblyBoard = bench.ui.board
		for i in range(board.pieces.size()):
			board.pieces[i].position = board.slots[i].position
			board.pieces[i].rotation = board.slots[i].rotation
			check(board.try_snap(board.pieces[i]), "mold components fit")
		await get_tree().process_frame
		await get_tree().process_frame
	check(bench.carried_mold == &"rectangle", "completed rectangle occupies hands")
	await near(machine.position + Vector2(0, 65))
	machine.production_time = 0.05
	click()
	check(hands.is_empty(), "Mouse1 inserts rectangle mold")
	await get_tree().create_timer(0.15).timeout
	var product: PhysicalItem
	for item in get_tree().get_nodes_in_group("ground_carryables"):
		if item.item_data == FirstCycle.RECTANGLE and item.mold_shape == &"":
			product = item
	check(product != null, "rectangle machine outputs a physical product")
	if product == null:
		get_tree().quit(1)
		return
	await near(product.position + Vector2(0, 55))
	click()
	check(hands.product == FirstCycle.RECTANGLE, "Mouse1 picks up rectangle")
	await near(Vector2(1800, -1072))
	click()
	check(hands.is_empty(), "rectangle can be dropped")
	click()
	check(hands.product == FirstCycle.RECTANGLE, "rectangle can be recovered")
	await near(room.get_node("shop_node").position + Vector2(0, 65))
	cycle.order_quantity = 2
	click()
	check(hands.is_empty() and cycle.counter_stock.get(FirstCycle.RECTANGLE, 0) == 1, "rectangle joins counter pile")
	cycle.deposit_product(FirstCycle.RECTANGLE)
	check(cycle.delivered == 1 and cycle.counter_stock[FirstCycle.RECTANGLE] == 0, "rectangle delivery consumes required stack")
	check(cycle.counter_stock[FirstCycle.SQUARE] == 1, "other product stacks remain")
	cycle.advance_time(cycle.arrival_delay + 0.1)
	check(cycle.order_item == FirstCycle.TRIANGLE, "triangle customers remain in cycle two")
	cycle._clear_order()
	cycle._spawn_order()
	check(cycle.order_item == FirstCycle.SQUARE, "square customers remain in cycle two")
	cycle._clear_order()
	cycle._spawn_order()
	check(cycle.order_item == FirstCycle.RECTANGLE, "rectangle customers recur")
	if DisplayServer.get_name() != "headless":
		cycle.order_quantity = 5
		cycle.deposit_product(FirstCycle.RECTANGLE)
		cycle.deposit_product(FirstCycle.RECTANGLE)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 720))
		var camera: Camera2D = player.get_node("FollowCamera")
		camera.position_smoothing_enabled = false
		camera.force_update_scroll()
		GameUI.notification_label.hide()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/second_cycle.png")
	cycle.advance_time(cycle.time_left)
	check(cycle.finished and not cycle.has_next_cycle(), "second cycle ends the current session")
	hud._start()
	cycle.set_process(false)
	check(cycle.cycle_number == 1 and cycle.counter_stock.is_empty() and cycle.score == 0, "restart resets progression and stock")
	check(not machine.manual_available and not bench.available_shapes.has(&"rectangle"), "restart relocks rectangle")
	print("SECOND CYCLE: %d checks, %d failures" % [checks, failures])
	await get_tree().process_frame
	get_tree().quit(1 if failures else 0)
