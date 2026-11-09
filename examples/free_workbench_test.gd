extends Node2D
var checks := 0
var failures := 0
var bench: MoldWorkbench
var ui
var board
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _ready() -> void:
	run.call_deferred()
func square(angle: float = 0.0) -> void:
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(220, 140))
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(450, 220))
	var a: ShapePiece = board.pieces[0]
	var b: ShapePiece = board.pieces[1]
	a.rotation = angle
	b.rotation = angle + PI
	b.position = a.position + Vector2(40, 40).rotated(angle)
	check(board.try_snap(a), "free square recognized regardless of translation/rotation")
func run() -> void:
	var room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	room.get_node("HUD")._start()
	var cycle = room.get_node("FirstCycle")
	cycle.set_process(false)
	bench = room.get_node("MoldWorkbench")
	bench.open_workbench()
	ui = bench.ui
	board = ui.board
	await get_tree().process_frame
	check(board.free_mode and board.pieces.is_empty() and board.hint == null, "free empty table with no recipe selected")
	check(bench.can_supply(&"triangle") and not bench.can_supply(&"square"), "unlimited triangles but no free squares")
	check(ui.recipe_buttons[&"rectangle"].disabled, "rectangle recipe locked in cycle one")
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(200, 150))
	var piece: ShapePiece = board.pieces[0]
	var double_click := InputEventMouseButton.new()
	double_click.button_index = MOUSE_BUTTON_LEFT
	double_click.pressed = true
	double_click.double_click = true
	double_click.position = piece.position
	board._gui_input(double_click)
	check(is_equal_approx(piece.rotation_degrees, 90), "double click rotates idle piece")
	ui._return_pieces()
	for quarter in range(4):
		square(quarter * PI / 2.0)
	check(bench.stored_molds.get(&"square", 0) == 4 and board.pieces.is_empty(), "crafted squares stored on shelf")
	ui._supply_piece(ui.PIECES[&"square"], Vector2(200, 150))
	check(bench.stored_molds[&"square"] == 3, "drag reserves one finite mold")
	ui.close_ui()
	check(bench.stored_molds[&"square"] == 4, "closing refunds unfinished pieces")
	bench.open_workbench()
	check(bench.stored_molds[&"square"] == 4, "shelf persists after reopening")
	ui._supply_piece(ui.PIECES[&"square"], Vector2(200, 150))
	ui._supply_piece(ui.PIECES[&"square"], Vector2(320, 150))
	check(board.pieces.size() == 2, "locked rectangle cannot be assembled")
	ui._return_pieces()
	cycle.advance_time(cycle.time_left)
	cycle.start_next_cycle()
	cycle.set_process(false)
	bench.open_workbench()
	check(bench.stored_molds[&"square"] == 4, "shelf survives cycle transition")
	ui._supply_piece(ui.PIECES[&"square"], Vector2(200, 150))
	ui._supply_piece(ui.PIECES[&"square"], Vector2(320, 150))
	check(bench.stored_molds[&"square"] == 2 and bench.stored_molds.get(&"rectangle", 0) == 1, "two squares consumed for rectangle without recipe selection")
	check(bench.take_stored(&"rectangle") and bench.carried_mold == &"rectangle", "take completed mold to machine")
	check(bench.stored_molds[&"rectangle"] == 0, "taking removes mold from shelf")
	check(not bench.take_stored(&"triangle"), "one object in hands")
	bench.carried_mold = &""
	bench.open_workbench()
	ui.guide.button_pressed = true
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(180, 160))
	ui._supply_piece(ui.PIECES[&"triangle"], Vector2(520, 240))
	check(board.pieces.size() == 2 and board.hint != null, "optional hint does not consume or replace pieces")
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/free_workbench.png")
	bench.reset_session()
	check(bench.stored_molds.is_empty(), "new game clears shelf and unfinished pieces")
	bench.set_session_active(true)
	bench.mold_mode = MoldWorkbench.MoldMode.UNLOCK_READY
	bench.open_workbench()
	square()
	check(bench.can_take_ready(&"square") and bench.supply(&"square") and bench.supply(&"square"), "optional unlock-ready mode preserved")
	print("FREE WORKBENCH: ", checks, " checks, ", failures, " failures")
	get_tree().quit(0 if failures == 0 else 1)
