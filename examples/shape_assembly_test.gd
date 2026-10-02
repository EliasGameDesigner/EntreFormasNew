extends Node

var failures: int = 0
var checks: int = 0
var completion_count: int = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	await test_board()
	await test_machine("res://entities/machines/maquina_quadrados.tscn")
	await test_machine("res://entities/machines/maquina_retangulos.tscn")
	await test_triangle()
	await test_external_systems()
	await test_world()
	# Allow the audio mixer to release MP3 voices before this very short run exits.
	for player in AudioManager.get_children():
		if player is AudioStreamPlayer:
			player.stop()
	await get_tree().create_timer(0.2).timeout
	print("ASSEMBLY TESTS: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func test_board() -> void:
	var board: ShapeAssemblyBoard = load("res://ui/machine_repair/shape_assembly_board.tscn").instantiate()
	add_child(board)
	var recipe: AssemblyDefinition = load("res://data/machines/assembly_square.tres")
	check(board.setup(recipe), "valid square recipe")
	board.size = recipe.board_size
	board.assembly_completed.connect(func(): completion_count += 1)
	await get_tree().process_frame
	var first := board.pieces[0]
	var second := board.pieces[1]
	var wrong: ShapePiece = board.add_piece(load("res://data/items/shape_square.tres"), board.slots[0].position)
	check(not board.try_snap(wrong), "wrong piece rejected")
	check(not board.try_snap(first), "distant piece rejected")
	second.position = board.slots[1].position
	check(not board.try_snap(second), "correct position / wrong rotation rejected")
	first.position = board.slots[0].position + Vector2(12, 0)
	first.rotation_degrees = 8
	check(board.try_snap(first), "position and rotation tolerance")
	check(first.position == board.slots[0].position and is_zero_approx(first.rotation), "exact snap transform")
	check(not board.is_fully_assembled(), "one slot does not complete")
	second.position = first.position
	check(not board.try_snap(second), "occupied slot rejected")
	check(board.begin_drag(first, first.position + Vector2(4, 5)), "remove snapped piece")
	check(board.slots[0].occupant == null, "slot released")
	board.move_drag(Vector2(100, 100))
	check(first.position.is_equal_approx(Vector2(96, 95)), "grab offset maintained")
	board.end_drag(Vector2(-1000, -1000))
	check(first.slot == board.slots[0], "outside release returns and resnaps")
	board.slots[0].definition = board.slots[0].definition.duplicate()
	board.slots[0].definition.allow_removal = false
	check(not board.begin_drag(first, first.position), "locked slot cannot be removed")
	second.position = Vector2(550, 170)
	# Exercise the same GUI/input handlers used by Mouse1 and R.
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = second.position
	board._gui_input(press)
	check(board.dragged_piece == second, "Mouse1 picks actual polygon")
	var rotate := InputEventAction.new()
	rotate.action = "rotate_piece"
	rotate.pressed = true
	board._input(rotate)
	board._input(rotate)
	check(is_equal_approx(second.rotation_degrees, 180.0), "rotation input")
	var motion := InputEventMouseMotion.new()
	motion.position = board.get_global_transform_with_canvas() * board.slots[1].position
	board._input(motion)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.position = motion.position
	board._input(release)
	check(board.is_fully_assembled() and board.completed, "Mouse1 release completes assembly")
	check(completion_count == 1, "completion emitted exactly once")
	check(not board.try_snap(second) and not board.begin_drag(first, first.position), "completed assembly locked")
	check(completion_count == 1, "no repeated completion")
	check(not board.setup(AssemblyDefinition.new()), "empty definition rejected")
	check(board.pieces.is_empty() and board.slots.is_empty(), "reset removes pieces")
	var optional_recipe: AssemblyDefinition = recipe.duplicate(true)
	optional_recipe.slots[1].required = false
	board.setup(optional_recipe)
	first = board.pieces[0]
	first.position = board.slots[0].position
	first.rotation = board.slots[0].rotation + TAU
	check(board.try_snap(first) and board.completed, "optional slots / wrapped angle")
	board.queue_free()
	await get_tree().process_frame

func test_machine(scene_path: String) -> void:
	var machine: MachineNode = load(scene_path).instantiate()
	machine.machine_data = machine.machine_data.duplicate()
	machine.machine_data.repair_cash_cost = 10
	add_child(machine)
	machine.repair_machine()
	machine.break_machine()
	check(machine.current_state == MachineNode.MachineState.BROKEN and machine.production_timer.is_stopped(), "break stops production")
	var data := machine.machine_data.repair_assembly.slots[0].piece
	var before: int = InventoryManager.get_all_items().get(data.inventory_item, 0)
	InventoryManager.add_item(data.inventory_item, 2)
	InventoryManager.money = 9
	machine.interactable.start_interaction(null)
	var ui := machine._repair_ui
	check(is_instance_valid(ui) and ui.visible, "interaction opens repair")
	await get_tree().process_frame
	await get_tree().process_frame
	ui._supply_from_tray(data)
	check(ui.assembly_board.pieces.size() == 1, "tray supplies loose piece")
	check(ui.assembly_board.get_filled_count() == 0, "click does not auto-slot")
	check(InventoryManager.get_all_items().get(data.inventory_item, 0) == before + 1, "reserve exactly once")
	ui.close_ui()
	check(InventoryManager.get_all_items().get(data.inventory_item, 0) == before + 2, "cancel refunds")
	check(not get_tree().get_first_node_in_group("modal_repair_ui"), "cancel unblocks player")
	machine.interactable.start_interaction(null)
	ui._supply_from_tray(data)
	ui._supply_from_tray(data)
	ui._supply_from_tray(data)
	check(ui.assembly_board.pieces.size() == 2, "supply limited to recipe")
	var board := ui.assembly_board
	# Real Viewport events also verify Control routing, not only model methods.
	await get_tree().process_frame
	for i in range(2):
		var piece := board.pieces[i]
		var press := InputEventMouseButton.new()
		press.button_index = MOUSE_BUTTON_LEFT
		press.pressed = true
		press.position = board.get_global_transform_with_canvas() * piece.position
		press.global_position = press.position
		var hover := InputEventMouseMotion.new()
		hover.position = press.position
		hover.global_position = press.position
		get_viewport().push_input(hover, true)
		get_viewport().push_input(press, true)
		check(board.dragged_piece == piece, "viewport Mouse1 picks piece")
		var steps := roundi(board.slots[i].definition.target_rotation_degrees / data.rotation_step_degrees)
		for step in range(steps):
			var key := InputEventKey.new()
			key.physical_keycode = KEY_R
			key.pressed = true
			get_viewport().push_input(key, true)
		var motion := InputEventMouseMotion.new()
		motion.position = board.get_global_transform_with_canvas() * board.slots[i].position
		get_viewport().push_input(motion, true)
		var release := InputEventMouseButton.new()
		release.button_index = MOUSE_BUTTON_LEFT
		release.position = motion.position
		get_viewport().push_input(release, true)
		check(piece.slot == board.slots[i], "viewport drag/drop snaps expected slot")
	await get_tree().process_frame
	check(machine.current_state == MachineNode.MachineState.BROKEN and ui.visible, "insufficient money does not repair")
	InventoryManager.money = 20
	await get_tree().process_frame
	await get_tree().process_frame
	check(machine.current_state == MachineNode.MachineState.WORKING, "assembly repairs machine automatically")
	check(not ui.visible and board.pieces.is_empty(), "successful repair closes and clears")
	check(InventoryManager.money == 10, "cash charged once")
	check(InventoryManager.get_all_items().get(data.inventory_item, 0) == before, "pieces consumed once")
	check(not machine.production_timer.is_stopped() and machine.animated_sprite.animation == &"funcionando", "production and animation resume")
	var count := get_child_count()
	machine._on_production_timer_timeout()
	check(get_child_count() == count + 1, "physical production preserved")
	machine.break_machine()
	machine.interactable.start_interaction(null)
	check(ui.visible and not board.completed, "second repair resets session")
	InventoryManager.add_item(data.inventory_item)
	ui._supply_from_tray(data)
	machine.queue_free()
	await get_tree().process_frame
	check(InventoryManager.has_item(data.inventory_item), "removing machine refunds pending piece")

func test_triangle() -> void:
	var machine: MachineNode = load("res://entities/machines/maquina_triangulos.tscn").instantiate()
	machine.current_state = MachineNode.MachineState.BROKEN
	add_child(machine)
	machine.breakage_chance = 1.0
	machine.break_machine()
	machine._on_breakage_timer_timeout()
	check(machine.current_state == MachineNode.MachineState.WORKING, "triangle never breaks, including initial broken override")
	check(machine.breakage_timer.is_stopped(), "triangle has no break timer")
	check(not machine.production_timer.is_stopped(), "triangle still produces")
	machine.queue_free()
	await get_tree().process_frame

func test_external_systems() -> void:
	# Resource-consuming tasks and selling share the same inventory as repair.
	for item in InventoryManager.get_all_items():
		InventoryManager.remove_item(item, InventoryManager.get_all_items()[item])
	var square: ItemData = load("res://data/items/itemQuadrado.tres")
	InventoryManager.add_item(square, 3)
	InventoryManager.money = 0
	var shop: ShopNode = load("res://entities/props/shop_node.tscn").instantiate()
	add_child(shop)
	shop.interactable.start_interaction(null)
	check(InventoryManager.money == square.price * 3 and not InventoryManager.has_item(square), "shop sells normally")
	shop.queue_free()
	var task: TaskNode = load("res://entities/tasks/tarefa_conserta_buraco.tscn").instantiate()
	add_child(task)
	InventoryManager.add_item(task.required_item, task.required_amount)
	var required := task.required_item
	task.interactable.start_interaction(null)
	task._on_interaction_progress(task.time_to_complete)
	check(task.is_queued_for_deletion() and not InventoryManager.has_item(required), "task consumes its own resources")
	await get_tree().process_frame

func test_world() -> void:
	var scene: PackedScene = load("res://world/cenario.tscn")
	check(scene != null, "world resources load")
	var world := scene.instantiate()
	add_child(world)
	await get_tree().process_frame
	check(world.is_inside_tree(), "world and external systems initialize")
	world.queue_free()
	await get_tree().process_frame
