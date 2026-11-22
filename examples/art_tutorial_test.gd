extends Node2D
var checks := 0
var failures := 0
var room: Node2D
var player
var hands
var cycle: FirstCycle
var art: ArtTutorial
var ui

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _ready() -> void:
	run.call_deferred()

func ground() -> Array:
	return get_tree().get_nodes_in_group("ground_carryables").filter(func(item): return not item._collected and not item.is_queued_for_deletion())

func pickup(item: PhysicalItem) -> void:
	player.position = item.position + Vector2(0, 40)
	player.reset_physics_interpolation()
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(hands.take(item), "physical pickup succeeds")

func fabricate(machine: MachineNode, shape: StringName) -> void:
	check(machine.request_manual_production(), "matching mold starts machine")
	check(art.step == StringName("wait_" + str(shape)), "Art notices active fabrication")
	machine._on_production_timer_timeout()
	check(art.step == StringName("pickup_" + str(shape)), "Art notices actual output")
	var product = ground().filter(func(item): return item.mold_shape == &"" and item.item_data == machine.machine_data.produced_item)[0]
	await pickup(product)
	check(art.step == StringName("deposit_" + str(shape)), "Art teaches carrying to counter")

func deposit() -> void:
	check(cycle.deposit_product(hands.product), "counter accepts product")
	hands.clear()

func screenshot(path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	GameUI.notification_label.hide()
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)

func run() -> void:
	room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 720))
		await get_tree().process_frame
		await get_tree().process_frame
	cycle = room.get_node("FirstCycle")
	art = room.get_node("ArtTutorial")
	ui = art.get_node("ArtUI")
	player = room.get_node("CharacterBody2D")
	player.set_physics_process(false)
	hands = player.get_node("Hands")
	var bench := cycle.mold_workbench
	check(not ui.visible, "Art does not cover initial menu")
	room.get_node("HUD")._enter_workshop()
	check(art.step == &"welcome" and ui.visible, "Art introduces himself during first preparation")
	check(not player.controls_blocked(), "Art dialogue does not block walking or interaction")
	check(ui.panel.mouse_filter == Control.MOUSE_FILTER_IGNORE and ui.speech.mouse_filter == Control.MOUSE_FILTER_IGNORE, "only tutorial buttons consume clicks")
	check(ui.speech.get_theme_font("font") == preload("res://assets/fonts/m5x7.ttf"), "Art uses supplied m5x7 font")
	await screenshot("res://docs/images/art_tutorial_welcome.png")
	check(cycle.start_prepared_cycle(), "normal counter start still works")
	cycle.set_process(false)
	check(art.step == &"take_triangle", "first live lesson asks for triangle mold")
	var time_before := cycle.time_left
	cycle.advance_time(1)
	check(cycle.time_left == time_before - 1, "tutorial does not pause service clock")
	check(bench.open_workbench() and bench.take_stored(&"triangle"), "take triangle from normal shelf")
	check(art.step == &"insert_triangle", "Art explains matching machine")
	check(hands.drop(), "mold can be dropped during lesson")
	art.refresh()
	check(art.step == &"recover_mold", "dropped mold has recovery guidance")
	await pickup(ground()[0])
	check(art.step == &"insert_triangle", "recovering mold resumes correct instruction")
	await fabricate(cycle.triangle_machine, &"triangle")
	await screenshot("res://docs/images/art_tutorial.png")
	deposit()
	check(cycle.counter_stock.get(FirstCycle.TRIANGLE, 0) == 1 and art.step == &"take_triangle", "incomplete order asks to repeat production")
	check(bench.take_stored(&"triangle"), "new fabrication requires fresh mold")
	await fabricate(cycle.triangle_machine, &"triangle")
	deposit()
	check(cycle.delivered == 1 and art.step == &"assemble_square", "delivery advances to square composition")
	cycle.advance_time(cycle.arrival_delay + 0.1)
	check(bench.open_workbench(), "normal free workbench remains available")
	await get_tree().process_frame
	await get_tree().process_frame
	check(bench.ui.board.get_global_rect().encloses(ui.panel.get_global_rect()), "Art fits in workbench corner")
	check(not ui.panel.get_global_rect().intersects(bench.ui.recipe_buttons[&"square"].get_global_rect()), "Art leaves recipe controls accessible")
	await screenshot("res://docs/images/art_tutorial_workbench.png")
	for i in 2:
		if not bench.ui.visible:
			bench.open_workbench()
		bench.ui._supply_piece(bench.ui.PIECES[&"triangle"], Vector2(220, 140))
		bench.ui._supply_piece(bench.ui.PIECES[&"triangle"], Vector2(450, 220))
		var a: ShapePiece = bench.ui.board.pieces[0]
		var b: ShapePiece = bench.ui.board.pieces[1]
		b.rotation = PI
		b.position = a.position + Vector2(40, 40)
		check(bench.ui.board.try_snap(a), "actual free assembly creates square")
		check(art.step == &"take_square", "Art explains completed mold shelf")
		check(bench.take_stored(&"square"), "take assembled square")
		check(art.step == &"insert_square", "square mold has matching-machine lesson")
		await fabricate(cycle.square_machine, &"square")
		deposit()
	check(cycle.delivered == 2 and art.step == &"complete", "tutorial completes after crafting and deliveries")
	ui.dismiss_button.pressed.emit()
	check(art.dismissed and not ui.panel.visible and ui.resume_button.visible, "tutorial can be dismissed")
	ui.resume_button.pressed.emit()
	check(not art.dismissed and ui.panel.visible, "current lesson can be reopened")
	cycle.finish_round()
	check(not ui.visible, "first-cycle end hides tutorial")
	cycle.start_prepared_cycle()
	cycle.set_process(false)
	check(cycle.cycle_number == 2 and not ui.visible, "no tutorial in later cycles")
	cycle.finish_round()
	cycle.prepare_session()
	check(art.milestones.is_empty() and not art.dismissed and art.step == &"welcome", "fresh session resets lessons and dismissal")
	cycle.start_prepared_cycle()
	cycle.set_process(false)
	cycle.advance_time(cycle.order_time_left)
	check(cycle.missed == 1 and art.step == &"take_triangle", "expired order never completes lesson falsely")
	cycle.advance_time(cycle.arrival_delay + 0.1)
	check(art.step == &"assemble_square", "lesson follows new customer after expiry")
	print("ART TUTORIAL: %d checks, %d failures" % [checks, failures])
	await get_tree().process_frame
	get_tree().quit(1 if failures else 0)
