extends Node2D

const CustomerVisual = preload("res://entities/props/customer_sprite.gd")
var failures := 0
var checks := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1152, 720))
	var room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	var cycle: FirstCycle = room.get_node("FirstCycle")
	var customer = room.get_node("Customer")
	check(not customer.visible, "no customer before starting")
	cycle.start_round()
	cycle.set_process(false)
	check(customer.visible, "starting the round shows a customer")
	check(customer.walking and customer.flip_h, "arrival walks toward the counter")
	var previous := -1
	for batch in range(5):
		var seen: Array[int] = []
		for i in range(4):
			var selected: int = customer.current_variant
			check(selected != previous, "consecutive customers differ, including bag boundaries")
			check(not seen.has(selected), "all four customers appear in each shuffle bag")
			check(is_equal_approx(customer.texture.get_height() * customer.scale.y, 80.0), "customer height matches the player")
			seen.append(selected)
			previous = selected
			cycle.changed.emit()
			check(customer.current_variant == selected, "HUD updates preserve customer appearance")
			cycle._clear_order()
			check(customer.current_variant == selected, "departing customer keeps their appearance")
			if batch < 4 or i < 3:
				cycle._spawn_order()
	await get_tree().create_timer(1.8).timeout
	check(not customer.visible, "customer disappears after leaving")
	cycle._spawn_order()
	check(customer.current_variant != previous, "new arrival after a gap does not repeat")
	await get_tree().create_timer(1.8).timeout
	check(not customer.walking and not customer.flip_h, "arrival stops in front-facing idle")
	if DisplayServer.get_name() != "headless":
		var player = room.get_node("CharacterBody2D")
		player.position = room.get_node("shop_node").position + Vector2(-150, 80)
		var camera: Camera2D = player.get_node("FollowCamera")
		camera.position_smoothing_enabled = false
		await get_tree().physics_frame
		camera.force_update_scroll()
		cycle.changed.emit()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/customer_in_factory.png")
	cycle.finish_round()
	check(customer.walking and not customer.flip_h, "departure walks in the opposite direction")
	await get_tree().create_timer(1.8).timeout
	check(not customer.visible, "round end removes the customer")
	cycle.start_round()
	cycle.set_process(false)
	check(customer.visible, "restart shows another customer")
	room.queue_free()
	await get_tree().process_frame
	GameUI.hide()
	get_viewport().canvas_transform = Transform2D.IDENTITY
	var background := ColorRect.new()
	background.color = Color("28221e")
	background.size = Vector2(1152, 720)
	add_child(background)
	add_label("CLIENTES DA FÁBRICA", Vector2(48, 50), 30)
	add_label("Mesma altura no jogo • quatro aparências alternadas", Vector2(48, 95), 20)
	var names := ["Jogador", "Artesã", "Artesão", "Comerciante", "Agricultora"]
	for i in range(5):
		var sprite: Sprite2D
		if i == 0:
			sprite = Sprite2D.new()
			sprite.texture = preload("res://entities/player/worker_frames.tres").get_frame_texture("Walk_Idle", 0)
			sprite.scale = Vector2.ONE * 0.19 * 2.5
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			var cutout := ShaderMaterial.new()
			cutout.shader = preload("res://entities/player/sprite_alpha.gdshader")
			sprite.material = cutout
			add_child(sprite)
		else:
			sprite = CustomerVisual.new()
			add_child(sprite)
			sprite.display_height = 200.0
			sprite._apply_visual(i - 1)
		var x := 125.0 + i * 225.0
		sprite.position = Vector2(x, 345)
		add_label(names[i], Vector2(x - 80, 490), 20)
	add_label("Repouso frontal • caminhada lateral na entrada e na saída", Vector2(48, 620), 19)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/customer_variants.png")
	print("CUSTOMER VISUAL TEST: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func add_label(text: String, at: Vector2, size: int) -> void:
	var label := Label.new()
	label.text = text
	label.position = at
	label.add_theme_font_size_override("font_size", size)
	add_child(label)
