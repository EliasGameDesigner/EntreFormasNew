extends Node

const TRIANGLE = FirstCycle.TRIANGLE
const SQUARE = FirstCycle.SQUARE
var checks := 0
var failures := 0
var room: Node2D
var cycle: FirstCycle
var triangle: MachineNode
var square: MachineNode
var player: CharacterBody2D
var workbench: MoldWorkbench

func _ready() -> void:
	run.call_deferred()

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("FAIL: " + message)

func quantity(item: ItemData) -> int:
	return InventoryManager.get_all_items().get(item, 0)

func run() -> void:
	room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	cycle = room.get_node("FirstCycle")
	triangle = cycle.triangle_machine
	square = cycle.square_machine
	workbench = cycle.mold_workbench
	player = room.get_node("CharacterBody2D")
	triangle.production_time = 0.1
	square.production_time = 0.1
	await get_tree().process_frame
	check(room.has_node("TileMapLayer"), "original factory remains in use")
	check(not cycle.running and not workbench.session_active, "intro blocks both manufacturing and workbench")
	check(not triangle.request_manual_production(), "intro cannot produce")
	check(workbench.mold_mode == MoldWorkbench.MoldMode.ALWAYS_ASSEMBLE, "default requires rebuilding every mold")
	check(not workbench.open_workbench(), "cannot open workbench before round")
	await screenshot("intro")
	room.get_node("HUD")._start()
	cycle.set_process(false)
	check(not triangle.request_manual_production(), "empty hands cannot produce even triangle")
	check(not square.request_manual_production(), "products are not a substitute for molds")
	check(cycle.order_item == TRIANGLE and cycle.order_quantity == 2, "opening order is two triangle products")
	var locked: MachineNode = room.get_node("MaquinaGenerica2")
	check(not locked.manual_available and locked.interactable.collision_layer == 0, "future station remains locked")
	var camera: Camera2D = player.get_node("FollowCamera")
	var camera_before := camera.global_position
	player.position += Vector2(100, 0)
	check(camera.global_position == camera_before + Vector2(100, 0), "camera follows player")
	player.position -= Vector2(100, 0)
	check(await walk_to(workbench.global_position + Vector2(0, 80)), "workbench reachable from spawn")
	await physics_frames()
	check(player.current_interactable == workbench.get_node("Interactable"), "proximity selects workbench")
	await click_at(workbench.get_global_transform_with_canvas() * Vector2.ZERO)
	check(workbench.ui.visible, "world interaction opens mold selection")
	await screenshot("choices")
	await click_at(workbench.ui.shape_buttons[&"triangle"].get_global_rect().get_center())
	check(workbench.carried_mold == &"triangle" and not workbench.ui.visible, "triangle button supplies a carried mold")
	check(quantity(TRIANGLE) == 0, "taking a mold does not create a product")
	check(player.get_node("CarriedMold").visible, "carried mold is visible on player")
	check(not cycle.deliver_order(), "molds cannot satisfy product deliveries")
	check(not workbench.begin_mold(&"triangle"), "one mold at a time")
	check(await walk_to(triangle.global_position + Vector2(0, 95)), "carry mold from workbench to triangle machine")
	await physics_frames()
	await screenshot("carrying")
	await click_at(triangle.get_global_transform_with_canvas() * Vector2.ZERO)
	check(workbench.carried_mold == &"", "insertion consumes carried mold")
	await get_tree().create_timer(0.15).timeout
	player.position = triangle.spawn_point.global_position
	await physics_frames()
	check(quantity(TRIANGLE) == 1, "machine produces and pickup collects one triangle")
	triangle._on_production_timer_timeout()
	check(quantity(TRIANGLE) == 1, "stale timeout does not duplicate output")
	await prepare_mold(&"triangle")
	check(triangle.request_manual_production(), "each new triangle requires another mold")
	check(not triangle.request_manual_production(), "busy machine cannot accept twice")
	await get_tree().create_timer(0.15).timeout
	await physics_frames()
	check(quantity(TRIANGLE) == 2, "second mold produces second triangle")
	var counter: ShopNode = room.get_node("shop_node")
	check(await walk_to(counter.global_position + Vector2(-80, -40)), "walk to counter through original map")
	await physics_frames()
	await click_at(counter.get_global_transform_with_canvas() * Vector2.ZERO)
	check(cycle.delivered == 1 and quantity(TRIANGLE) == 0 and cycle.score == 20, "deliver products for reward")
	check(not cycle.deliver_order(), "duplicate delivery rejected")
	cycle.advance_time(cycle.arrival_delay + 0.1)
	check(cycle.order_item == SQUARE and cycle.order_quantity == 2, "second order requests squares")
	check(await walk_to(workbench.global_position + Vector2(0, 80)), "return to workbench in same map")
	check(workbench.open_workbench() and workbench.begin_mold(&"square"), "square mold starts from two free triangular molds")
	check(workbench.steps == [&"square"] and quantity(TRIANGLE) == 0, "square assembly uses molds, never product inventory")
	var before := cycle.order_time_left
	cycle.advance_time(2.0)
	check(cycle.order_time_left == before - 2.0, "order clock continues during mold assembly")
	await get_tree().process_frame
	var hud := room.get_node("HUD")
	for panel in [hud._stock_panel, hud._order_panel, hud._clock_panel]:
		check(not workbench.ui.panel.get_global_rect().intersects(panel.get_global_rect()), "HUD remains outside mold board")
	await screenshot("assembly")
	await click_at(workbench.ui.close_button.get_global_rect().get_center())
	check(not workbench.ui.visible and workbench.carried_mold == &"" and workbench.steps.is_empty(), "GUI cancellation clears preparation without spawning mold")
	for i in range(2):
		await prepare_mold(&"square")
		check(workbench.carried_mold == &"square", "completed square mold can be carried")
		check(not triangle.request_manual_production() and workbench.carried_mold == &"square", "wrong machine does not consume mold")
		player.position = square.spawn_point.global_position
		check(square.request_manual_production(), "matching mold starts square machine")
		check(workbench.carried_mold == &"" and quantity(SQUARE) == i, "no product before manufacturing delay")
		await get_tree().create_timer(0.15).timeout
		await physics_frames()
	check(quantity(SQUARE) == 2, "two separately assembled molds make two squares")
	check(not workbench.can_take_ready(&"square"), "known square still requires assembly in default mode")
	await screenshot("ready")
	check(await walk_to(counter.global_position + Vector2(-80, -40)), "square products carried to counter")
	await physics_frames()
	await click_at(counter.get_global_transform_with_canvas() * Vector2.ZERO)
	check(cycle.delivered == 2 and quantity(SQUARE) == 0 and cycle.score == 80, "complete mold-production-delivery loop")
	check(room.get_node("CompraParalelogramos/Label").text.contains("próximo ciclo"), "reward preserves progression locks")
	await test_modes_and_rectangle()
	cycle.advance_time(cycle.arrival_delay + 0.1)
	cycle.advance_time(cycle.order_time_left + 0.1)
	check(cycle.running and cycle.missed == 1 and not cycle.deliver_order(), "expired order cannot deliver, round continues")
	# One machine runs while another mold is being prepared; expiry cancels both.
	await prepare_mold(&"triangle")
	triangle.production_time = 60.0
	check(triangle.request_manual_production(), "machine can work while player prepares another mold")
	check(workbench.open_workbench() and workbench.begin_mold(&"square"), "workbench remains usable during machine production")
	snap_current_step()
	cycle.finish_round()
	await get_tree().process_frame
	check(not workbench.ui.visible and workbench.carried_mold == &"", "round end cancels pending completed board")
	check(not triangle._mold_cycle_active and triangle.production_timer.is_stopped(), "round end stops unfinished manufacturing")
	check(not workbench.open_workbench() and not triangle.request_manual_production(), "round end blocks workbench and machines")
	await screenshot("result")
	room.get_node("HUD")._start()
	cycle.set_process(false)
	check(cycle.running and cycle.delivered == 0 and cycle.score == 0, "retry resets orders and score")
	check(workbench.unlocked_molds == [&"triangle"] and workbench.carried_mold == &"", "retry resets discovered and carried molds")
	check(InventoryManager.get_all_items().is_empty(), "retry clears products")
	check(workbench.open_workbench() and workbench.begin_mold(&"triangle"), "retry is playable")
	if DisplayServer.get_name() != "headless":
		check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN, "fullscreen startup")
		await toggle_fullscreen()
		check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED, "F11 exits fullscreen")
		await toggle_fullscreen()
		check(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN, "F11 restores fullscreen")
	cycle.finish_round()
	room.queue_free()
	for child in AudioManager.get_children():
		if child is AudioStreamPlayer:
			child.stop()
	await get_tree().process_frame
	print("FIRST CYCLE MOLD TESTS: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func test_modes_and_rectangle() -> void:
	workbench.available_shapes.append(&"rectangle")
	check(workbench.open_workbench() and workbench.begin_mold(&"rectangle"), "rectangle recipe can be enabled for future cycles")
	check(workbench.steps == [&"square", &"square", &"rectangle"], "rectangle requires two square molds from triangles then final assembly")
	await solve_step()
	check(workbench.carried_mold == &"" and workbench.step_index == 1, "intermediate square stays in preparation, not in hands")
	await solve_step()
	await solve_step()
	check(workbench.carried_mold == &"rectangle", "three assemblies yield one rectangle mold")
	check(quantity(SQUARE) == 0 and quantity(TRIANGLE) == 0, "recursive mold building never adds products")
	var rectangle: MachineNode = room.get_node("MaquinaGenerica2")
	check(not rectangle.request_manual_production() and workbench.carried_mold == &"rectangle", "locked machine preserves carried mold")
	rectangle.set_manual_available(true)
	rectangle.production_time = 0.1
	check(rectangle.request_manual_production(), "rectangle mold works when its machine is enabled")
	await get_tree().create_timer(0.15).timeout
	player.position = rectangle.spawn_point.global_position
	await physics_frames()
	check(quantity(MoldWorkbench.PRODUCTS[&"rectangle"]) == 1, "rectangle mold yields exactly one rectangle product")
	rectangle.set_manual_available(false)
	InventoryManager.remove_item(MoldWorkbench.PRODUCTS[&"rectangle"])
	workbench.mold_mode = MoldWorkbench.MoldMode.UNLOCK_READY
	workbench.unlocked_molds.assign([&"triangle"])
	check(not workbench.can_take_ready(&"square"), "unlock mode still requires first square assembly")
	await prepare_mold(&"square")
	workbench.discard_carried()
	check(workbench.can_take_ready(&"square"), "first successful square unlocks ready copies")
	check(workbench.open_workbench() and workbench.begin_mold(&"square"), "ready square can be taken after discovery")
	check(workbench.steps.is_empty() and workbench.carried_mold == &"square", "unlocked copy skips puzzle")
	workbench.discard_carried()
	check(workbench.open_workbench() and workbench.begin_mold(&"rectangle"), "new rectangle still needs discovery")
	check(workbench.steps == [&"rectangle"], "unlocked square molds supply rectangle ingredients in unlock mode")
	await solve_step()
	workbench.discard_carried()
	check(workbench.open_workbench() and workbench.begin_mold(&"rectangle") and workbench.steps.is_empty(), "discovered rectangle is available ready")
	workbench.discard_carried()
	workbench.mold_mode = MoldWorkbench.MoldMode.ALWAYS_ASSEMBLE
	check(workbench.open_workbench() and workbench.begin_mold(&"rectangle"), "switching mode applies to next preparation")
	check(workbench.steps.size() == 3, "always mode rebuilds intermediates even after discovery")
	workbench.ui.close_ui()
	check(workbench.carried_mold == &"", "cancelled recursive preparation gives no final mold")
	workbench.available_shapes.erase(&"rectangle")

func prepare_mold(shape: StringName) -> void:
	check(workbench.open_workbench() and workbench.begin_mold(shape), "begin requested mold")
	while not workbench.steps.is_empty():
		await solve_step()

func snap_current_step() -> void:
	var board: ShapeAssemblyBoard = workbench.ui.board
	for i in range(board.pieces.size()):
		var piece := board.pieces[i]
		piece.position = board.slots[i].position
		piece.rotation = board.slots[i].rotation
		check(board.try_snap(piece), "correct mold piece fits slot")

func solve_step() -> void:
	snap_current_step()
	await get_tree().process_frame
	await get_tree().process_frame

func physics_frames() -> void:
	for i in range(4):
		await get_tree().physics_frame
	await get_tree().process_frame

func screenshot(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--screenshots"):
		return
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://first_cycle_%s.tmp.png" % label)

func click_at(at: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = at
	get_viewport().push_input(motion, true)
	await get_tree().process_frame
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = at
		get_viewport().push_input(event, true)
		await get_tree().process_frame

func walk_to(destination: Vector2) -> bool:
	player.set_physics_process(false)
	var reached := true
	for i in range(200):
		var displacement := destination - player.global_position
		if displacement.length() < 1.0:
			break
		var collision := player.move_and_collide(displacement.limit_length(12.0))
		if collision:
			reached = false
			break
		await get_tree().physics_frame
	player.set_physics_process(true)
	return reached and player.global_position.distance_to(destination) < 1.0

func toggle_fullscreen() -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_F11
		event.pressed = pressed
		get_viewport().push_input(event, true)
		await get_tree().process_frame
