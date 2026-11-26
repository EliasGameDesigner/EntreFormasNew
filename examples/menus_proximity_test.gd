extends Node
## Keeps the harness alive through real scene transitions and SceneTree pauses.
var checks := 0
var failures := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func frames(count: int = 3) -> void:
	for i in count:
		await get_tree().process_frame

func cancel() -> void:
	var key := InputEventKey.new()
	key.keycode = KEY_ESCAPE
	key.physical_keycode = KEY_ESCAPE
	key.pressed = true
	Input.parse_input_event(key)
	await frames(2)
	key = InputEventKey.new()
	key.keycode = KEY_ESCAPE
	key.physical_keycode = KEY_ESCAPE
	Input.parse_input_event(key)
	await frames(2)

func near(player: CharacterBody2D, position: Vector2) -> void:
	player.position = position
	player.reset_physics_interpolation()
	await get_tree().physics_frame
	await get_tree().physics_frame

func screenshot(path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await frames()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	run.call_deferred()

func run() -> void:
	# A persistent runner, separate from the scenes being changed by the menus.
	get_tree().current_scene = null
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://ui/menus/main_menu.tscn", "F5 opens main menu")
	get_tree().change_scene_to_file("res://ui/menus/main_menu.tscn")
	await frames()
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 720))
		await frames()
	var menu = get_tree().current_scene
	check(get_tree().get_first_node_in_group("first_cycle") == null, "no gameplay or customers exist behind initial menu")
	check(not GameUI.visible, "initial menu hides gameplay HUD")
	check(menu.play_button.has_focus(), "play has keyboard focus")
	check(menu.quit_button.text == "Sair do jogo", "initial menu has exit option")
	await screenshot("res://docs/images/main_menu.png")
	menu.play_button.pressed.emit()
	await frames(5)
	var room = get_tree().current_scene
	var cycle: FirstCycle = room.get_node("FirstCycle")
	var pause = room.get_node("PauseMenu")
	var player: CharacterBody2D = room.get_node("CharacterBody2D")
	var bench := cycle.mold_workbench
	var machine := cycle.triangle_machine
	check(cycle.preparing and not cycle.running, "play enters preparation without starting clock")
	check(not room.get_node("HUD")._overlay.visible, "no duplicate initial intro after main menu")
	check(GameUI.visible and room.get_node("ArtTutorial/ArtUI").visible, "HUD and Art start normally")
	check(pause.pause_button.visible, "pause button available in preparation")
	check(pause.layer > bench.ui.layer, "pause overlays workbench UI")
	player.set_physics_process(false)
	await near(player, Vector2(1552, -1072))
	for item in [cycle.triangle_machine, cycle.square_machine, cycle.rectangle_machine, cycle.parallelogram_machine, cycle.trapezoid_machine]:
		check(not item.status_label.visible, "distant machine text hidden")
	await near(player, machine.global_position + Vector2(0, 100))
	check(machine.status_label.visible, "nearby machine label shown")
	await screenshot("res://docs/images/nearby_machine_label.png")
	await near(player, machine.global_position + Vector2(0, 170))
	check(machine.status_label.visible, "exit margin prevents boundary flicker")
	await near(player, machine.global_position + Vector2(0, 210))
	check(not machine.status_label.visible, "walking away hides text")
	var locked := cycle.rectangle_machine
	await near(player, locked.global_position + Vector2(0, 100))
	check(locked.status_label.visible and locked.status_label.text.contains("ciclo 2"), "locked machine still explains unlock when approached")
	await near(player, Vector2(1552, -1072))
	pause.pause_button.pressed.emit()
	check(get_tree().paused and pause.overlay.visible, "pause works during preparation")
	pause.resume_button.pressed.emit()
	check(not get_tree().paused and cycle.preparing, "continue restores preparation")
	cycle.start_prepared_cycle()
	await frames()
	check(bench.take_stored(&"triangle"), "carry a mold before pausing")
	machine.production_time = 2.0
	check(machine.request_manual_production(), "production can start normally")
	await cancel()
	check(get_tree().paused and pause.overlay.visible, "Escape opens pause during play")
	var cycle_time := cycle.time_left
	var order_time := cycle.order_time_left
	var production_time := machine.production_timer.time_left
	var customer_position: Vector2 = room.get_node("Customer").position
	var player_position := player.position
	player.set_physics_process(true)
	Input.action_press("right")
	await get_tree().create_timer(0.25, true).timeout
	Input.action_release("right")
	check(is_equal_approx(cycle.time_left, cycle_time), "pause freezes round clock")
	check(is_equal_approx(cycle.order_time_left, order_time), "pause freezes customer patience")
	check(is_equal_approx(machine.production_timer.time_left, production_time), "pause freezes fabrication timer")
	check(room.get_node("Customer").position == customer_position, "pause freezes customer walk tween")
	check(player.position == player_position, "pause freezes player movement")
	check(pause.resume_button.has_focus(), "continue receives keyboard focus")
	await screenshot("res://docs/images/pause_menu.png")
	await cancel()
	check(not get_tree().paused and not pause.overlay.visible, "Escape resumes paused game")
	await get_tree().create_timer(0.08).timeout
	check(cycle.time_left < cycle_time and machine.production_timer.time_left < production_time, "timers resume from preserved values")
	player.set_physics_process(false)
	check(bench.open_workbench(), "workbench can open after resume")
	await frames()
	check(not pause.pause_button.visible, "pause shortcut does not cover modal close buttons")
	await cancel()
	check(not bench.ui.visible and not get_tree().paused, "first Escape closes workbench instead of pausing")
	await cancel()
	check(get_tree().paused, "next Escape pauses game")
	pause.resume_button.pressed.emit()
	cycle.deposit_product(FirstCycle.SQUARE)
	pause.pause_game()
	pause.main_menu_button.pressed.emit()
	await frames(5)
	check(not get_tree().paused and get_tree().current_scene.scene_file_path == "res://ui/menus/main_menu.tscn", "return to main menu unpauses and changes scene")
	check(get_tree().get_first_node_in_group("first_cycle") == null and not GameUI.visible, "return removes gameplay and HUD")
	get_tree().current_scene.play_button.pressed.emit()
	await frames(5)
	room = get_tree().current_scene
	cycle = room.get_node("FirstCycle")
	check(cycle.preparing and cycle.counter_stock.is_empty() and cycle.score == 0, "playing again starts fresh session")
	check(not get_tree().paused and room.get_node("ArtTutorial").step == &"welcome", "new game restores input and tutorial")
	print("MENUS AND PROXIMITY: %d checks, %d failures" % [checks, failures])
	await frames()
	get_tree().quit(1 if failures else 0)
