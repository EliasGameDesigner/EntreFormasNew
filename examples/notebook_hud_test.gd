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

func screenshot(path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)

func run() -> void:
	var room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	if "--small" in OS.get_cmdline_user_args() and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 720))
		await get_tree().process_frame
		await get_tree().process_frame
	var cycle: FirstCycle = room.get_node("FirstCycle")
	var hud = room.get_node("HUD")
	var notebook = hud._stock
	var font = preload("res://assets/fonts/m5x7.ttf")
	check(hud._clock.get_theme_font("font") == font, "clock uses attached font")
	check(notebook.money.get_theme_font("font") == font, "ledger uses attached font")
	check(GameUI.notification_label.get_theme_font("font") == font, "global notifications use attached font")
	check(room.get_node("CharacterBody2D/InteractionLabel").get_theme_font("font") == font, "world labels use attached font")
	check(font.has_char("ã".unicode_at(0)) and font.has_char("é".unicode_at(0)), "font supports Portuguese accents")
	hud._enter_workshop()
	cycle.set_process(false)
	for i in notebook.ITEMS.size():
		check(notebook.rows[notebook.ITEMS[i]].visible == (i < 2), "only unlocked stock rows appear in first cycle")
	cycle.counter_stock[FirstCycle.SQUARE] = 2
	cycle.score = 135
	cycle.changed.emit()
	check(notebook.counts[FirstCycle.SQUARE].text == "× 2", "deposits update quantity")
	check(notebook.money.text == "Moedas: 135", "money tracks score")
	check(hud._clock.text.contains("PREPARAÇÃO"), "preparation has its own header")
	await get_tree().process_frame
	check(get_viewport().get_visible_rect().encloses(notebook.get_global_rect()), "notebook fits viewport")
	check(get_viewport().get_visible_rect().encloses(hud._clock_panel.get_global_rect()), "top header fits viewport")
	check(not notebook.get_global_rect().intersects(hud._clock_panel.get_global_rect()), "header and ledger do not overlap")
	for child in hud._root.get_children():
		check(not (child is Label and child.text.contains("WASD")), "no controls footer")
	GameUI.notification_label.hide()
	await screenshot("res://docs/images/notebook_hud_preparation.png")
	cycle.start_prepared_cycle()
	for next_cycle in 3:
		cycle.finish_round()
		cycle.start_prepared_cycle()
	for i in notebook.ITEMS.size():
		var item: ItemData = notebook.ITEMS[i]
		cycle.counter_stock[item] = i + 1
	cycle.score = 245
	cycle.changed.emit()
	for item in notebook.ITEMS:
		check(notebook.rows[item].visible, "all five rows unlocked by cycle four")
		check(notebook.counts[item].text == "× %d" % cycle.counter_stock[item], "each icon has its own quantity")
	check(hud._clock.text.contains("CICLO 4"), "header tracks cycle progression")
	var hands = get_tree().get_first_node_in_group("player_hands")
	hands.product = FirstCycle.RECTANGLE
	hands.changed.emit()
	check(notebook.held_icon.texture == FirstCycle.RECTANGLE.icon, "held product shown separately")
	check(notebook.counts[FirstCycle.RECTANGLE].text == "× 3", "held product does not count as deposited")
	hands.product = null
	hands.changed.emit()
	cycle.mold_workbench.carried_mold = &"square"
	cycle.mold_workbench.changed.emit()
	check(notebook.held_icon.texture == preload("res://data/items/square_mold_texture.tres"), "held mold uses mold icon")
	await get_tree().process_frame
	await screenshot("res://docs/images/notebook_hud.png")
	print("NOTEBOOK HUD: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
