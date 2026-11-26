extends Node2D
const Indicator = preload("res://entities/player/interaction_indicator.gd")
var checks := 0
var failures := 0
var player
var indicator
func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)
func near(point: Vector2) -> void:
	player.position = point
	player.reset_physics_interpolation()
	player.get_node("FollowCamera").reset_physics_interpolation()
	await get_tree().physics_frame
	await get_tree().physics_frame
	player.interaction.refresh_prompt()
func capture(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		GameUI.notification_label.hide()
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/interaction_%s.png" % name)
func _ready() -> void:
	run.call_deferred()
func run() -> void:
	var room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	var cycle: FirstCycle = room.get_node("FirstCycle")
	var bench := cycle.mold_workbench
	player = room.get_node("CharacterBody2D")
	player.set_physics_process(false)
	indicator = player.get_node("InteractionIndicator")
	player.interaction.refresh_prompt()
	check(not indicator.visible, "welcome hides interaction indicator")
	room.get_node("HUD")._button.pressed.emit()
	await near(Vector2(1800, -1072))
	check(not indicator.visible, "empty floor has no interaction indicator")
	await near(bench.position + Vector2(0, 80))
	check(not indicator.visible, "bench has no available-action icon before tutorial starts")
	cycle.start_prepared_cycle()
	cycle.set_process(false)
	player.interaction.refresh_prompt()
	check(indicator.kind == Indicator.Kind.INTERACT and indicator.visible, "workbench shows exclamation")
	check(not player.interaction.interaction_label.visible, "old text prompt stays hidden")
	check(indicator.position.y < -55 and indicator.scale == Vector2.ONE, "indicator is fixed size above head")
	await capture("station")
	var item := preload("res://entities/resources/physical_item.tscn").instantiate()
	item.item_data = FirstCycle.SQUARE
	item.position = player.position + Vector2(60, 0)
	room.add_child(item)
	await get_tree().physics_frame
	await get_tree().physics_frame
	player.interaction.refresh_prompt()
	check(indicator.kind == Indicator.Kind.PICKUP and indicator.texture == Indicator.GLOVE, "pickup glove takes priority over workbench")
	await capture("pickup")
	check(player.get_node("Hands").take(item), "glove corresponds to a reachable item")
	player.interaction.refresh_prompt()
	check(indicator.kind == Indicator.Kind.NONE, "carrying a product during service does not offer mold workbench action")
	player.get_node("Hands").clear()
	await near(Vector2(1800, -1072))
	check(not indicator.visible, "indicator disappears after leaving targets")
	check(bench.take_stored(&"triangle"), "take a mold for drop test")
	check(player.get_node("Hands").drop(), "drop mold to floor")
	await get_tree().physics_frame
	player.interaction.refresh_prompt()
	check(indicator.kind == Indicator.Kind.PICKUP, "ground molds also show glove")
	await near(room.get_node("shop_node").position + Vector2(0, 65))
	check(indicator.kind == Indicator.Kind.INTERACT, "customer counter shows exclamation")
	await near(cycle.rectangle_machine.position + Vector2(0, 80))
	check(not indicator.visible, "locked machine shows no interaction icon")
	await near(cycle.triangle_machine.position + Vector2(0, 95))
	check(indicator.kind == Indicator.Kind.INTERACT, "available machine shows exclamation")
	bench.carried_mold = &"triangle"
	bench.changed.emit()
	cycle.triangle_machine.production_time = 0.15
	check(cycle.triangle_machine.request_manual_production(), "start machine for unavailable-state test")
	player.interaction.refresh_prompt()
	check(not indicator.visible, "busy machine hides indicator")
	await get_tree().create_timer(0.25).timeout
	player.interaction.refresh_prompt()
	check(indicator.kind == Indicator.Kind.PICKUP, "machine output switches to pickup glove")
	bench.open_workbench()
	player.interaction.refresh_prompt()
	check(not indicator.visible, "modal workbench hides indicator")
	bench.ui.close_ui()
	player.interaction.refresh_prompt()
	check(indicator.visible, "closing modal restores available action")
	print("INTERACTION INDICATOR: %d checks, %d failures" % [checks, failures])
	await get_tree().process_frame
	get_tree().quit(1 if failures else 0)
