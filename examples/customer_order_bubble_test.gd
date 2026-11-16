extends Node2D
var checks := 0
var failures := 0
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func _ready() -> void:
	run.call_deferred()
func run() -> void:
	var room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	var cycle: FirstCycle = room.get_node("FirstCycle")
	var hud = room.get_node("HUD")
	var bubble = room.get_node("CustomerOrderBubble")
	var customer = room.get_node("Customer")
	check(not bubble.visible, "no order before opening")
	hud._start()
	cycle.set_process(false)
	check(bubble.visible and bubble.icon.texture == cycle.order_item.icon and bubble.quantity.text == "× 2", "order appears immediately with icon and quantity")
	check(not hud._order_panel.visible, "order moved out of fixed HUD card")
	check(not room.get_node("CharacterBody2D").controls_blocked(), "bubble does not block player input")
	check(bubble.panel.mouse_filter == Control.MOUSE_FILTER_IGNORE and bubble.icon.mouse_filter == Control.MOUSE_FILTER_IGNORE, "bubble ignores mouse actions")
	await get_tree().create_timer(1.5).timeout
	check(bubble.visible, "order stays visible without interaction")
	var player = room.get_node("CharacterBody2D")
	player.set_physics_process(false)
	player.position = room.get_node("shop_node").position + Vector2(0, 85)
	player.reset_physics_interpolation()
	var camera: Camera2D = player.get_node("FollowCamera")
	camera.reset_smoothing()
	camera.reset_physics_interpolation()
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	check(not bubble.pinned and bubble.tail.visible, "bubble follows visible customer")
	check(bubble.panel.get_global_rect().end.y < (customer.get_global_transform_with_canvas() * Vector2.ZERO).y, "bubble is above customer")
	for item in [FirstCycle.TRIANGLE, FirstCycle.SQUARE, FirstCycle.RECTANGLE, FirstCycle.PARALLELOGRAM, FirstCycle.TRAPEZOID]:
		cycle.order_item = item
		cycle.order_quantity = 3
		cycle.order_reward = 30
		cycle.changed.emit()
		check(bubble.icon.texture == item.icon and bubble.quantity.text == "× 3", "every shape uses correct icon")
	cycle.deposit_product(FirstCycle.TRAPEZOID)
	check(bubble.progress.text.begins_with("1/3"), "counter deposits update progress")
	cycle.advance_time(2)
	check(bubble.patience.value == cycle.order_time_left, "patience stays synchronized")
	if DisplayServer.get_name() != "headless":
		GameUI.notification_label.hide()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/customer_order_bubble.png")
	player.position = Vector2(1200, -1100)
	player.reset_physics_interpolation()
	camera.reset_smoothing()
	camera.reset_physics_interpolation()
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	check(bubble.pinned and bubble.visible and bubble.location.visible, "order stays on screen when customer is outside camera")
	check(get_viewport().get_visible_rect().encloses(bubble.panel.get_global_rect()), "pinned order fits screen")
	cycle.deposit_product(FirstCycle.TRAPEZOID)
	cycle.deposit_product(FirstCycle.TRAPEZOID)
	check(not bubble.visible and cycle.delivered == 1, "delivery clears bubble")
	cycle.advance_time(cycle.arrival_delay + 0.1)
	check(bubble.visible and bubble.icon.texture == cycle.order_item.icon, "new customer updates bubble")
	cycle.advance_time(cycle.order_time_left)
	check(not bubble.visible, "expired order clears bubble")
	cycle.advance_time(cycle.arrival_delay + 0.1)
	cycle.finish_round()
	check(not bubble.visible, "intermission clears bubble")
	print("CUSTOMER ORDER BUBBLE: %d checks, %d failures" % [checks, failures])
	await get_tree().process_frame
	get_tree().quit(1 if failures else 0)
