extends Node2D
var checks := 0
var failures := 0
var player
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func near(point: Vector2) -> void:
	player.position = point
	player.reset_physics_interpolation()
	await get_tree().physics_frame
	await get_tree().physics_frame
func action() -> void:
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	player._unhandled_input(event)
	event.pressed = false
	player._unhandled_input(event)
func _ready() -> void:
	run.call_deferred()
func run() -> void:
	var room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 720))
		await get_tree().process_frame
		await get_tree().process_frame
	var cycle: FirstCycle = room.get_node("FirstCycle")
	var hud = room.get_node("HUD")
	var bench := cycle.mold_workbench
	var ui = bench.ui
	var counter = room.get_node("shop_node")
	var service_ui = counter.service_ui
	player = room.get_node("CharacterBody2D")
	player.set_physics_process(false)
	var hands = player.get_node("Hands")
	check(not cycle.workshop_active(), "welcome is not an active session")
	hud._button.pressed.emit()
	check(cycle.preparing and not cycle.running and cycle.order_item == null, "welcome enters preparation without opening orders")
	check(not hud._overlay.visible and not player.controls_blocked(), "preparation permits free movement")
	check(hands.enabled() and not cycle.triangle_machine.manual_available and not bench.session_active, "initial preparation locks molds and production")
	check(cycle.initial_tutorial_pending(), "first lesson is pending before counter start")
	cycle.advance_time(10000)
	check(cycle.time_left == 0 and cycle.customer_number == 0, "waiting before tutorial has no clock or arrivals")
	var marker = room.get_node("TutorialStartMarker")
	await get_tree().process_frame
	check(marker.visible and marker.pinned, "counter direction is visible when destination is outside camera")
	check(get_viewport().get_visible_rect().encloses(marker.panel.get_global_rect()), "tutorial marker stays on screen")
	check(marker.caption.text.contains("INICIAR TUTORIAL"), "marker clearly names the starting action")
	await near(bench.position + Vector2(0, 80))
	action()
	check(not ui.visible and not bench.open_workbench(), "interaction and direct opening cannot bypass initial lock")
	check(not bench.can_supply(&"triangle") and not bench.take_stored(&"triangle"), "unlimited triangle supply is also locked")
	check(not bench.begin_mold(&"square"), "sequential assembly cannot bypass lock")
	bench.store_assembled(&"square")
	check(bench.stored_molds.is_empty() and bench.carried_mold == &"", "blocked assembly cannot create stock or a carried mold")
	check(GameUI.notification_label.text.contains("balcão de atendimento"), "blocked opening explains where to begin")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/tutorial_start_direction.png")
	await near(counter.position + Vector2(0, 65))
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		# Camera interpolation and screen-space marker settle after the rendered frame.
		await RenderingServer.frame_post_draw
	check(not marker.pinned and marker.visible, "marker identifies the actual counter when camera reaches it")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/tutorial_start_counter.png")
	action()
	check(service_ui.visible and service_ui.start_cycle_button.text == "Iniciar tutorial", "counter explicitly offers tutorial start")
	check(service_ui.explanation.text.contains("bancada será liberada"), "start dialog explains assembly unlock")
	service_ui.close_ui()
	check(cycle.initial_tutorial_pending() and not bench.session_active, "closing start dialog keeps assembly locked")
	action()
	if DisplayServer.get_name() != "headless":
		GameUI.notification_label.hide()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/cycle_preparation_counter.png")
	service_ui.start_cycle_button.pressed.emit()
	cycle.set_process(false)
	check(cycle.running and not cycle.preparing and cycle.time_left == cycle.round_duration, "counter begins tutorial and timed cycle")
	check(not cycle.initial_tutorial_pending() and not marker.visible, "starting removes tutorial destination marker")
	check(not service_ui.visible and bench.session_active and cycle.triangle_machine.manual_available, "starting unlocks bench and production")
	check(bench.open_workbench(), "free assembly becomes available after tutorial starts")
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(220, 140))
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(450, 220))
	ui.board.pieces[1].position = Vector2(260, 180)
	ui.board.pieces[1].rotation = PI
	check(ui.board.try_snap(ui.board.pieces[1]) and bench.stored_molds.get(&"square", 0) == 1, "assembly works after unlock")
	ui.close_ui()
	check(bench.take_stored(&"triangle"), "triangle mold can be taken after unlock")
	cycle.deposit_product(FirstCycle.TRIANGLE)
	service_ui.start_cycle_button.pressed.emit()
	check(cycle.customer_number == 1 and cycle.cycle_number == 1, "duplicate start cannot reset or skip cycle")
	cycle.triangle_machine.production_time = 0.15
	check(cycle.triangle_machine.request_manual_production(), "manufacturing starts before end of cycle")
	bench.open_workbench()
	ui._supply_piece(ui.PIECES[&"square"], Vector2(200, 140))
	cycle.finish_round()
	check(cycle.preparing and cycle.finished and not cycle.running and not hud._overlay.visible and bench.session_active, "later preparation remains free after first cycle")
	check(not marker.visible and not cycle.initial_tutorial_pending(), "tutorial start marker stays off between cycles")
	check(not ui.visible and bench.stored_molds[&"square"] == 1, "intermission returns loose table molds")
	check(cycle.triangle_machine._mold_cycle_active, "manufacturing survives boundary")
	await get_tree().create_timer(0.25).timeout
	check(not cycle.triangle_machine._mold_cycle_active, "manufacturing completes during interval")
	cycle.advance_time(10000)
	check(cycle.order_item == null and cycle.cycle_number == 1 and cycle.time_left == 0, "waiting never starts next cycle")
	check(not cycle.rectangle_machine.manual_available, "new machines unlock when their cycle starts")
	for next_cycle in [2, 3, 4]:
		await near(counter.position + Vector2(0, 65))
		action()
		check(service_ui.visible, "open counter between cycles")
		check(service_ui.start_cycle_button.text == "Iniciar ciclo %d" % next_cycle, "counter identifies next cycle")
		service_ui.start_cycle_button.pressed.emit()
		cycle.set_process(false)
		check(cycle.running and cycle.cycle_number == next_cycle and cycle.order_item != null, "counter starts requested next cycle")
		cycle.finish_round()
	check(cycle.finished and not cycle.preparing and not cycle.workshop_active() and hud._overlay.visible, "last cycle displays final result")
	hud._button.pressed.emit()
	check(cycle.preparing and cycle.cycle_number == 1 and cycle.counter_stock.is_empty() and bench.stored_molds.is_empty(), "new session returns to clean preparation")
	check(cycle.initial_tutorial_pending() and not bench.session_active and marker.visible, "restart restores initial lock and counter marker")
	print("CYCLE PREPARATION: %d checks, %d failures" % [checks, failures])
	await get_tree().process_frame
	get_tree().quit(1 if failures else 0)
