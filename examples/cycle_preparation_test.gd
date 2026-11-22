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
	check(hands.enabled() and cycle.triangle_machine.manual_available and bench.session_active, "transport, machines and bench work before first cycle")
	cycle.advance_time(10000)
	check(cycle.time_left == 0 and cycle.customer_number == 0, "preparation has no clock or arrivals")
	await near(bench.position + Vector2(0, 80))
	action()
	await get_tree().process_frame
	check(ui.visible and not ui.has_method("_start_cycle"), "mold workbench only handles mold preparation")
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(220, 140))
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(450, 220))
	ui.board.pieces[1].position = Vector2(260, 180)
	ui.board.pieces[1].rotation = PI
	check(ui.board.try_snap(ui.board.pieces[1]) and bench.stored_molds.get(&"square", 0) == 1, "molds can be assembled in preparation")
	ui.close_ui()
	check(bench.take_stored(&"triangle"), "take triangle mold during preparation")
	cycle.triangle_machine.production_time = 0.05
	check(cycle.triangle_machine.request_manual_production(), "manufacture during preparation")
	await get_tree().create_timer(0.15).timeout
	var product: PhysicalItem
	for item in get_tree().get_nodes_in_group("ground_carryables"):
		if item.item_data == FirstCycle.TRIANGLE:
			product = item
	check(product != null, "preparation produces physical output")
	if product == null:
		get_tree().quit(1)
		return
	await near(product.position + Vector2(0, 55))
	action()
	check(hands.product == FirstCycle.TRIANGLE, "collect output before first customer")
	await near(room.get_node("shop_node").position + Vector2(0, 65))
	action()
	check(hands.is_empty() and cycle.counter_stock.get(FirstCycle.TRIANGLE, 0) == 1 and cycle.delivered == 0, "stock counter without delivering during preparation")
	check(bench.take_stored(&"triangle"), "carry a mold before starting")
	await near(bench.position + Vector2(0, 80))
	action()
	await get_tree().process_frame
	check(ui.visible and bench.carried_mold == &"triangle", "can open bench carrying a mold during preparation")
	ui.close_ui()
	await near(counter.position + Vector2(0, 65))
	action()
	check(service_ui.visible and service_ui.start_cycle_button.text == "Iniciar ciclo 1", "counter opens start dialog while carrying a mold")
	service_ui.close_ui()
	check(cycle.preparing and not player.controls_blocked(), "can return from counter to continue preparing")
	action()
	if DisplayServer.get_name() != "headless":
		GameUI.notification_label.hide()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/cycle_preparation_counter.png")
	service_ui.start_cycle_button.pressed.emit()
	cycle.set_process(false)
	check(cycle.running and not cycle.preparing and cycle.cycle_number == 1 and cycle.time_left == cycle.round_duration, "counter starts first timed cycle")
	check(not service_ui.visible and not player.controls_blocked() and cycle.order_item == FirstCycle.TRIANGLE, "starting closes bench and admits first customer")
	check(bench.stored_molds.get(&"square", 0) == 1 and bench.carried_mold == &"triangle" and cycle.counter_stock[FirstCycle.TRIANGLE] == 1, "starting preserves prepared stock and held mold")
	service_ui.start_cycle_button.pressed.emit()
	check(cycle.customer_number == 1 and cycle.cycle_number == 1, "duplicate start cannot reset or skip cycle")
	cycle.triangle_machine.production_time = 0.15
	check(cycle.triangle_machine.request_manual_production(), "manufacturing starts before end of cycle")
	bench.open_workbench()
	ui._supply_piece(ui.PIECES[&"square"], Vector2(200, 140))
	cycle.finish_round()
	check(cycle.preparing and cycle.finished and not cycle.running and not hud._overlay.visible, "intermission returns to free preparation")
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
	print("CYCLE PREPARATION: %d checks, %d failures" % [checks, failures])
	await get_tree().process_frame
	get_tree().quit(1 if failures else 0)
