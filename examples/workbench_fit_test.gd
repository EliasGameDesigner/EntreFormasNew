extends Node

var failures := 0

func check(value: bool, message: String) -> void:
	if not value:
		failures += 1
		push_error(message)

func _ready() -> void:
	run.call_deferred()

func capture(label: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/workbench_%s.png" % label)

func run() -> void:
	var room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	room.get_node("HUD")._start()
	var bench: MoldWorkbench = room.get_node("MoldWorkbench")
	bench.open_workbench()
	await get_tree().process_frame
	await capture("choices")
	bench.begin_mold(&"square")
	var board: ShapeAssemblyBoard = bench.ui.board
	# Keep the completed board visible only in this visual regression scene.
	for connection in board.assembly_completed.get_connections():
		board.assembly_completed.disconnect(connection.callable)
	await get_tree().process_frame
	await capture("assembly")
	check(board.pieces.size() == 2, "square uses two triangles")
	for i in range(board.pieces.size()):
		var piece := board.pieces[i]
		check(piece.definition.full_shape_art, "piece uses full silhouette artwork")
		check(piece.definition.icon.atlas.resource_path.ends_with("triangle_part_v3.png"), "right triangle art is active")
		check(piece.contains_point(piece.transform * Vector2(-20, -20)), "solid triangle area is draggable")
		check(not piece.contains_point(piece.transform * Vector2(70, 70)), "empty half of texture is not draggable")
		piece.position = board.slots[i].position
		piece.rotation = board.slots[i].rotation
		check(board.try_snap(piece), "metal triangle snaps into its matching cavity")
	check(board.is_fully_assembled(), "both triangles complete the square")
	# Their transformed vertex sets share exactly the diagonal endpoints.
	var shared := 0
	for a in board.pieces[0].definition.polygon:
		for b in board.pieces[1].definition.polygon:
			if (board.pieces[0].transform * a).is_equal_approx(board.pieces[1].transform * b):
				shared += 1
	check(shared == 2, "triangles share exactly their diagonal endpoints")
	await capture("fitted")
	print("WORKBENCH FIT: ", "PASS" if failures == 0 else "FAIL")
	get_tree().quit(0 if failures == 0 else 1)
