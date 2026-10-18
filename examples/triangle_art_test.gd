extends Node

@export_enum("triangle", "square") var shape: String = "triangle"

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	var room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	room.get_node("HUD")._start()
	var cycle: FirstCycle = room.get_node("FirstCycle")
	cycle.set_process(false)
	var player = room.get_node("CharacterBody2D")
	player.set_physics_process(false)
	cycle.mold_workbench.open_workbench()
	cycle.mold_workbench.begin_mold(StringName(shape))
	while not cycle.mold_workbench.steps.is_empty():
		var board: ShapeAssemblyBoard = cycle.mold_workbench.ui.board
		for i in range(board.pieces.size()):
			var piece = board.pieces[i]
			piece.position = board.slots[i].position
			piece.rotation = board.slots[i].rotation
			board.try_snap(piece)
		await get_tree().process_frame
		await get_tree().process_frame
	var item: ItemData = MoldWorkbench.PRODUCTS[StringName(shape)]
	player.update_animation(Vector2.DOWN)
	player.update_animation(Vector2.ZERO)
	var product = preload("res://entities/resources/physical_item.tscn").instantiate()
	product.item_data = item
	product.position = player.position + Vector2(110, 0)
	room.add_child(product)
	var size: Vector2 = product.sprite.texture.get_size() * product.sprite.scale
	var valid := is_equal_approx(maxf(size.x, size.y), 40.0)
	valid = valid and product.sprite.texture.resource_path.ends_with(shape + "_part_texture.tres")
	valid = valid and player.get_node("CarriedMold").visible
	valid = valid and cycle.mold_workbench.ui.shape_buttons[StringName(shape)].icon.resource_path.ends_with(shape + "_mold_texture.tres")
	if DisplayServer.get_name() != "headless":
		await get_tree().create_timer(0.5).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/%s_in_game.png" % shape)
	var before: int = InventoryManager.get_all_items().get(item, 0)
	product._on_body_entered(player)
	valid = valid and InventoryManager.get_all_items().get(item, 0) == before + 1
	print(shape.to_upper() + " ART: textures, world scale, carried mold, workbench icon and pickup: ", "PASS" if valid else "FAIL")
	get_tree().quit(0 if valid else 1)
