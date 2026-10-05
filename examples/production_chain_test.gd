extends Node2D

const TRIANGLE = preload("res://data/items/itemTriangulo.tres")
const SQUARE = preload("res://data/items/itemQuadrado.tres")
var checks := 0
var failures := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error("FAIL: " + message)

func quantity(item: ItemData) -> int:
	return InventoryManager.get_all_items().get(item, 0)

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	await test_production()
	await test_contention()
	await test_purchase_and_repairs()
	await test_pickup()
	for child in AudioManager.get_children():
		if child is AudioStreamPlayer:
			child.stop()
	await get_tree().create_timer(0.2).timeout
	print("PRODUCTION CHAIN TESTS: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func reset_inventory() -> void:
	for item in InventoryManager.get_all_items():
		InventoryManager.remove_item(item, quantity(item))

func spawn_machine(path: String, consuming: bool = false) -> MachineNode:
	var machine: MachineNode = load(path).instantiate()
	machine.current_state = MachineNode.MachineState.WORKING
	machine.consume_production_materials = consuming
	machine.breakage_chance = 0.0
	machine.production_time = 60.0
	add_child(machine)
	return machine

func remove_outputs() -> void:
	for child in get_children():
		if child is PhysicalItem:
			child.queue_free()

func test_production() -> void:
	reset_inventory()
	var machine := spawn_machine("res://entities/machines/maquina_quadrados.tscn", true)
	check(machine.waiting_for_materials and machine.production_timer.is_stopped(), "empty inventory waits")
	InventoryManager.add_item(TRIANGLE)
	await get_tree().process_frame
	check(quantity(TRIANGLE) == 1 and machine.waiting_for_materials, "incomplete recipe never partially debited")
	InventoryManager.add_item(TRIANGLE)
	await get_tree().process_frame
	check(quantity(TRIANGLE) == 0 and machine._cycle_active, "2 triangles reserved for 1 square")
	var remaining := machine.production_timer.time_left
	InventoryManager.add_item(TRIANGLE, 3)
	await get_tree().process_frame
	check(quantity(TRIANGLE) == 3 and machine.production_timer.time_left <= remaining, "inventory changes do not restart or double charge cycle")
	var before := get_child_count()
	machine._on_production_timer_timeout()
	check(get_child_count() == before + 1, "one output per completed cycle")
	check(quantity(TRIANGLE) == 1 and machine._cycle_active, "next cycle reserves another two")
	machine.break_machine()
	check(quantity(TRIANGLE) == 3 and machine.production_timer.is_stopped(), "break refunds interrupted cycle")
	machine.break_machine()
	machine._on_production_timer_timeout()
	check(quantity(TRIANGLE) == 3 and get_child_count() == before + 1, "repeat break and stale timeout produce nothing")
	machine.repair_machine()
	check(quantity(TRIANGLE) == 1 and machine._cycle_active, "repair restarts paid cycle")
	machine.stop_production()
	check(quantity(TRIANGLE) == 3, "explicit stop refunds")
	machine.start_production()
	check(quantity(TRIANGLE) == 1, "restart reserves once")
	machine.queue_free()
	await get_tree().process_frame
	check(quantity(TRIANGLE) == 3, "removing machine refunds pending cycle")
	remove_outputs()
	await get_tree().process_frame
	reset_inventory()
	machine = spawn_machine("res://entities/machines/maquina_quadrados.tscn")
	check(machine._cycle_active, "consumption is optional and off by default")
	before = get_child_count()
	machine._on_production_timer_timeout()
	check(get_child_count() == before + 1 and quantity(TRIANGLE) == 0, "free mode still produces")
	machine.queue_free()
	remove_outputs()
	await get_tree().process_frame
	machine = spawn_machine("res://entities/machines/maquina_trapezios.tscn", true)
	InventoryManager.add_item(SQUARE)
	InventoryManager.add_item(TRIANGLE)
	await get_tree().process_frame
	check(machine.waiting_for_materials and quantity(SQUARE) == 1 and quantity(TRIANGLE) == 1, "mixed recipe debit is atomic")
	InventoryManager.add_item(TRIANGLE)
	await get_tree().process_frame
	check(machine._cycle_active and quantity(SQUARE) == 0 and quantity(TRIANGLE) == 0, "trapezoid reserves square and two triangles")
	machine.production_timer.start(0.02)
	await get_tree().create_timer(0.08).timeout
	check(machine.waiting_for_materials and machine.production_timer.is_stopped(), "production pauses after last paid output")
	machine.queue_free()
	remove_outputs()
	await get_tree().process_frame
	# Cover the other two configured production recipes.
	for path in ["res://entities/machines/maquina_retangulos.tscn", "res://entities/machines/maquina_paralelogramos.tscn"]:
		machine = spawn_machine(path, true)
		var costs := machine.machine_data.production_recipe.get_requirements()
		InventoryManager.return_items(costs)
		await get_tree().process_frame
		check(machine._cycle_active and InventoryManager.get_all_items().is_empty(), "recipe consumed: " + path)
		machine._on_production_timer_timeout()
		check(machine.waiting_for_materials, "output completed: " + path)
		machine.queue_free()
		remove_outputs()
		await get_tree().process_frame

func test_contention() -> void:
	reset_inventory()
	var a := spawn_machine("res://entities/machines/maquina_quadrados.tscn", true)
	var b := spawn_machine("res://entities/machines/maquina_paralelogramos.tscn", true)
	InventoryManager.add_item(TRIANGLE, 2)
	await get_tree().process_frame
	check(a._cycle_active != b._cycle_active and quantity(TRIANGLE) == 0, "two machines cannot spend the same pair")
	var active := a if a._cycle_active else b
	var waiting := b if a._cycle_active else a
	active.break_machine()
	await get_tree().process_frame
	check(waiting._cycle_active and quantity(TRIANGLE) == 0, "refund wakes waiting machine")
	a.queue_free()
	b.queue_free()
	await get_tree().process_frame
	check(quantity(TRIANGLE) == 2, "no loss or duplication across competing machines")
	reset_inventory()

func make_purchase(scene_path: String, data_path: String, prerequisite_path: String) -> MachinePurchasePoint:
	var point: MachinePurchasePoint = load("res://entities/machines/machine_purchase_point.tscn").instantiate()
	point.machine_scene = load(scene_path)
	point.machine_data = load(data_path)
	point.unlock_after_repair = load(prerequisite_path)
	add_child(point)
	return point

func solve_repair(machine: MachineNode) -> void:
	machine.break_machine()
	machine.interactable.start_interaction(null)
	var ui := machine._repair_ui
	check(is_instance_valid(ui) and ui.visible, "new machine opens generic repair")
	for slot in machine.machine_data.repair_assembly.slots:
		InventoryManager.add_item(slot.piece.inventory_item)
		ui._supply_from_tray(slot.piece)
	var board := ui.assembly_board
	await get_tree().process_frame
	await get_tree().process_frame
	check_geometry(board)
	for i in range(board.slots.size()):
		var piece := board.pieces[i]
		var slot := board.slots[i]
		piece.position = slot.position
		piece.rotation = slot.rotation + deg_to_rad(45)
		check(not board.try_snap(piece), "wrong rotation rejected in new recipe")
		var press := InputEventMouseButton.new()
		press.button_index = MOUSE_BUTTON_LEFT
		press.pressed = true
		# Pick at the pivot using the same GUI handler as Mouse1.
		press.position = piece.position
		board._gui_input(press)
		check(board.dragged_piece == piece, "new piece can be picked")
		# Restore an exact multiple of the configured step, then rotate via input.
		piece.rotation = 0.0
		for step in range(roundi(slot.definition.target_rotation_degrees / piece.definition.rotation_step_degrees)):
			var rotate := InputEventAction.new()
			rotate.action = "rotate_piece"
			rotate.pressed = true
			board._input(rotate)
		var release := InputEventMouseButton.new()
		release.button_index = MOUSE_BUTTON_LEFT
		release.position = board.get_global_transform_with_canvas() * slot.position
		board._input(release)
		check(piece.slot == slot, "new recipe snap")
	await get_tree().process_frame
	check(machine.current_state == MachineNode.MachineState.WORKING and not ui.visible, "new recipe automatically repairs")
	check(machine.was_repaired, "real repair records progression")

func polygon_area(points: PackedVector2Array) -> float:
	var area := 0.0
	for i in range(points.size()):
		area += points[i].cross(points[(i + 1) % points.size()])
	return absf(area) * 0.5

func check_geometry(board: ShapeAssemblyBoard) -> void:
	var combined := PackedVector2Array()
	var area := 0.0
	for slot in board.slots:
		var points: PackedVector2Array = slot.transform * slot.definition.piece.polygon
		area += polygon_area(points)
		if combined.is_empty():
			combined = points
		else:
			var merged := Geometry2D.merge_polygons(combined, points)
			check(merged.size() == 1, "pieces share complete edges, no gaps")
			if merged.size() == 1:
				combined = merged[0]
	check(is_equal_approx(polygon_area(combined), area), "solution pieces do not overlap")
	check(is_equal_approx(polygon_area(Geometry2D.convex_hull(combined)), area), "solution silhouette is convex")

func test_purchase_and_repairs() -> void:
	var rectangle := spawn_machine("res://entities/machines/maquina_retangulos.tscn")
	var para := make_purchase("res://entities/machines/maquina_paralelogramos.tscn", "res://data/machines/maquinaParalelogramos.tres", "res://data/machines/maquinaRetangulos.tres")
	var trap := make_purchase("res://entities/machines/maquina_trapezios.tscn", "res://data/machines/maquinaTrapezios.tres", "res://data/machines/maquinaParalelogramos.tres")
	InventoryManager.money = 1000
	check(not para.try_purchase() and InventoryManager.money == 1000, "working prerequisite alone does not unlock")
	rectangle.break_machine()
	rectangle.repair_machine()
	check(para.is_unlocked(), "rectangle repair unlocks parallelogram")
	InventoryManager.money = 299
	check(not para.try_purchase() and InventoryManager.money == 299, "insufficient purchase funds unchanged")
	InventoryManager.money = 1000
	para.interactable.start_interaction(null)
	check(para.purchased and InventoryManager.money == 700, "interaction buys once for 300")
	check(para.purchased_machine.current_state == MachineNode.MachineState.WORKING and para.purchased_machine._cycle_active, "purchase delivers working machine")
	check(not para.try_purchase() and InventoryManager.money == 700, "purchase cannot be repeated")
	check(not trap.is_unlocked(), "purchase itself does not count as a repair")
	var machine := para.purchased_machine
	machine.breakage_chance = 0
	await solve_repair(machine)
	check(trap.is_unlocked(), "parallelogram repair unlocks trapezoid")
	check(trap.try_purchase() and InventoryManager.money == 200, "trapezoid costs 500")
	await get_tree().process_frame
	check(not para.interactable.monitorable and not trap.interactable.monitorable, "bought markers no longer intercept interaction")
	await solve_repair(trap.purchased_machine)
	machine.break_machine()
	check(trap.is_unlocked(), "unlock survives subsequent breakage")
	rectangle.queue_free()
	machine.queue_free()
	trap.purchased_machine.queue_free()
	para.queue_free()
	trap.queue_free()
	await get_tree().process_frame
	reset_inventory()

func test_pickup() -> void:
	var player: CharacterBody2D = load("res://entities/player/player.tscn").instantiate()
	player.position = Vector2(4000, 4000)
	add_child(player)
	check(player.is_in_group("player"), "real player belongs to pickup group")
	var item: PhysicalItem = load("res://entities/resources/physical_item.tscn").instantiate()
	item.item_data = TRIANGLE
	item.position = Vector2(4500, 4000)
	add_child(item)
	for frame in range(3):
		await get_tree().physics_frame
	check(quantity(TRIANGLE) == 0, "distant items stay on ground")
	check(item.find_children("*", "Interactable").is_empty(), "pickup does not steal Mouse1 interaction")
	var outsider := Node2D.new()
	add_child(outsider)
	item._on_body_entered(outsider)
	check(quantity(TRIANGLE) == 0, "only player can collect")
	outsider.queue_free()
	player.position = item.position
	for frame in range(4):
		await get_tree().physics_frame
	check(quantity(TRIANGLE) == 1 and not is_instance_valid(item), "walking into real Area2D auto-collects")
	item = load("res://entities/resources/physical_item.tscn").instantiate()
	item.item_data = SQUARE
	item.position = player.position
	add_child(item)
	for frame in range(4):
		await get_tree().physics_frame
	check(quantity(SQUARE) == 1 and not is_instance_valid(item), "item spawned beside stationary player is collected")
	item = load("res://entities/resources/physical_item.tscn").instantiate()
	item.item_data = TRIANGLE
	item.position = Vector2(6000, 4000)
	add_child(item)
	item._on_body_entered(player)
	item._on_body_entered(player)
	check(quantity(TRIANGLE) == 2, "duplicate pickup events cannot duplicate inventory")
	player.queue_free()
	await get_tree().process_frame
