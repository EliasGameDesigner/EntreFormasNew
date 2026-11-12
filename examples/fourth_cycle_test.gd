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
	var bench := cycle.mold_workbench
	var machine := cycle.trapezoid_machine
	var hands = player.get_node("Hands")
	hud._start()
	cycle.set_process(false)
	check(not machine.manual_available and not bench.can_supply(&"trapezoid"), "locked in cycle one")
	cycle.advance_time(cycle.time_left)
	hud._start()
	cycle.set_process(false)
	check(cycle.cycle_number == 2 and not machine.manual_available, "locked in cycle two")
	cycle.deposit_product(FirstCycle.SQUARE)
	bench.store_assembled(&"square")
	bench.store_assembled(&"square")
	cycle.advance_time(cycle.time_left)
	hud._start()
	cycle.set_process(false)
	check(cycle.cycle_number == 3 and not machine.manual_available, "locked in cycle three")
	cycle.advance_time(cycle.time_left)
	check(hud._button.text.contains("ciclo 4"), "HUD offers cycle four")
	hud._start()
	cycle.set_process(false)
	check(cycle.cycle_number == 4 and cycle.time_left == 240, "fourth cycle duration")
	check(machine.manual_available and machine.interactable.collision_layer == 1, "machine unlocks for interaction")
	check(cycle.counter_stock[FirstCycle.SQUARE] == 1 and bench.stored_molds[&"square"] == 2, "stock survives transition")
	check(cycle.order_item == FirstCycle.TRAPEZOID and cycle.order_quantity == 1, "first customer orders new shape")
	check(hud._stock.text.contains("Trapézios"), "HUD stock includes new product")
	bench.open_workbench()
	var ui = bench.ui
	var board = ui.board
	ui._supply_piece(ui.PIECES[&"square"], Vector2(340, 140))
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(240, 160))
	board.pieces[1].rotation = PI
	check(not board.try_snap(board.pieces[0]) and board.pieces.size() == 2, "two pieces cannot complete three-slot recipe")
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(500, 240))
	var last: ShapePiece = board.pieces[2]
	last.position = Vector2(440, 160)
	check(not board.try_snap(last), "incorrect orientation is rejected")
	last.rotation_degrees = 270
	check(board.try_snap(last), "square plus two triangles form trapezoid when last triangle released")
	check(bench.stored_molds.get(&"trapezoid", 0) == 1, "completed mold goes to shelf")
	ui.recipe_buttons[&"trapezoid"].pressed.emit()
	await get_tree().process_frame
	check(board.hint == MoldWorkbench.RECIPES[&"trapezoid"], "optional recipe guide")
	check(get_viewport().get_visible_rect().encloses(ui.panel.get_global_rect()), "all recipes fit viewport")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/fourth_cycle_workbench.png")
	check(bench.take_stored(&"trapezoid"), "take mold from shelf")
	await near(Vector2(1800, -1072))
	click()
	check(hands.is_empty(), "drop mold")
	click()
	check(bench.carried_mold == &"trapezoid", "recover mold")
	await near(machine.position + Vector2(0, 65))
	machine.production_time = 0.05
	click()
	check(hands.is_empty(), "Mouse1 inserts mold into new machine")
	await get_tree().create_timer(0.15).timeout
	var product: PhysicalItem
	for item in get_tree().get_nodes_in_group("ground_carryables"):
		if item.item_data == FirstCycle.TRAPEZOID and item.mold_shape == &"":
			product = item
	check(product != null, "machine produces physical trapezoid")
	if product == null:
		get_tree().quit(1)
		return
	await near(product.position + Vector2(0, 55))
	click()
	check(hands.product == FirstCycle.TRAPEZOID, "pick up new product")
	await near(Vector2(1800, -1072))
	click()
	click()
	check(hands.product == FirstCycle.TRAPEZOID, "drop and recover product")
	cycle.order_quantity = 3
	cycle.order_reward = 3 * cycle.trapezoid_reward
	await near(room.get_node("shop_node").position + Vector2(0, 65))
	click()
	cycle.deposit_product(FirstCycle.TRAPEZOID)
	check(cycle.counter_stock[FirstCycle.TRAPEZOID] == 2 and hands.is_empty(), "counter accumulates new shape")
	if DisplayServer.get_name() != "headless":
		GameUI.notification_label.hide()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/fourth_cycle.png")
	cycle.deposit_product(FirstCycle.TRAPEZOID)
	check(cycle.delivered == 1 and cycle.score == 210 and cycle.counter_stock[FirstCycle.TRAPEZOID] == 0, "delivery consumes stack and rewards")
	check(cycle.counter_stock[FirstCycle.SQUARE] == 1, "other stacks preserved")
	for expected in [FirstCycle.TRIANGLE, FirstCycle.SQUARE, FirstCycle.RECTANGLE, FirstCycle.PARALLELOGRAM, FirstCycle.TRAPEZOID]:
		cycle._clear_order()
		cycle._spawn_order()
		check(cycle.order_item == expected, "all shapes recur in customer orders")
	bench.open_workbench()
	for quarter in range(4):
		for released_index in range(3):
			bench.store_assembled(&"square")
			var recipe: AssemblyDefinition = MoldWorkbench.RECIPES[&"trapezoid"]
			var angle := quarter * PI / 2.0
			for entry in recipe.slots:
				check(bench.supply(entry.piece.shape_id), "reserve actual mold")
				board.add_piece(entry.piece, Vector2(60, 30) + entry.target_position.rotated(angle), entry.target_rotation_degrees + rad_to_deg(angle))
			check(board.try_snap(board.pieces[released_index]), "all rotations and all released components complete trapezoid")
			check(board.pieces.is_empty(), "all three components consumed exactly once")
	ui.close_ui()
	cycle.advance_time(cycle.time_left)
	check(cycle.finished and not cycle.has_next_cycle(), "cycle four ends session")
	hud._restart()
	check(cycle.cycle_number == 1 and not machine.manual_available and bench.stored_molds.is_empty(), "restart clears stock and relocks new machine")
	print("FOURTH CYCLE: %d checks, %d failures" % [checks, failures])
	await get_tree().process_frame
	get_tree().quit(1 if failures else 0)
