extends Node
var checks := 0
var failures := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	run.call_deferred()

func run() -> void:
	var room = preload("res://world/first_cycle.tscn").instantiate()
	room.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(room)
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1152, 720))
		await get_tree().process_frame
		await get_tree().process_frame
	room.get_node("HUD")._enter_workshop()
	var cycle: FirstCycle = room.get_node("FirstCycle")
	var art: ArtTutorial = room.get_node("ArtTutorial")
	var ui = art.get_node("ArtUI")
	var writer = ui.typewriter
	writer.set_process(false)
	var bips := [0]
	writer.blip_played.connect(func(): bips[0] += 1)
	check(writer.voice.stream != null and writer.voice.stream.get_length() > 0, "Art has a playable dialogue blip")
	check(ui.speech.visible_characters == 0 and writer.is_typing(), "new dialogue begins hidden")
	writer.set_message("Olá, Art!", "accent_test")
	writer.advance(0.03)
	check(ui.speech.visible_characters == 1 and bips[0] == 1, "first letter is revealed with a blip")
	writer.advance(0.03)
	writer.advance(0.03)
	check(ui.speech.visible_characters == 3 and ui.speech.text.left(3) == "Olá", "accented letters reveal correctly")
	var before_comma: int = bips[0]
	writer.advance(0.025)
	check(ui.speech.visible_characters == 4 and bips[0] == before_comma, "punctuation has no blip")
	writer.advance(0.04)
	check(ui.speech.visible_characters == 4, "comma adds a brief reading pause")
	var revealed: int = ui.speech.visible_characters
	writer.set_message("Olá, Art!", "accent_test")
	check(ui.speech.visible_characters == revealed, "refreshing same message never resets reveal")
	writer.set_message(" ,.!?", "silent_test")
	var silent_before: int = bips[0]
	writer.advance(1.0)
	check(bips[0] == silent_before, "whitespace and punctuation stay silent")
	writer.set_message("Art ensina a fabricar peças.", "hidden_test")
	art.dismiss()
	check(not ui.panel.visible and ui.resume_button.visible, "dismiss hides dialogue")
	var hidden_index: int = ui.speech.visible_characters
	var hidden_bips: int = bips[0]
	writer.advance(1.0)
	check(ui.speech.visible_characters == hidden_index and bips[0] == hidden_bips and not writer.voice.playing, "hidden dialogue has no animation or sound")
	art.refresh()
	check(art.dismissed and not ui.panel.visible, "same-step polling respects dismissal")
	art.resume()
	writer.advance(0.04)
	check(ui.panel.visible and ui.speech.visible_characters > 0, "manual resume continues reveal")
	ui.show_text_button.pressed.emit()
	check(ui.speech.visible_characters == -1 and not writer.is_typing(), "show all immediately completes current speech")
	check(not writer.voice.playing and ui.show_text_button.disabled, "show all stops blips and disables itself")
	art.dismiss()
	cycle.start_prepared_cycle()
	cycle.set_process(false)
	check(art.step == &"take_triangle" and not art.dismissed and ui.panel.visible, "starting tutorial reopens dismissed dialogue")
	check(ui.speech.visible_characters == 0 and writer.is_typing(), "new stage starts a fresh reveal")
	writer.advance(0.1)
	check(ui.speech.visible_characters > 0, "new message advances normally")
	art.dismiss()
	check(cycle.mold_workbench.take_stored(&"triangle"), "take real mold to advance lesson")
	check(art.step == &"insert_triangle" and ui.panel.visible and not art.dismissed, "next action reopens dismissed balloon automatically")
	check(ui.speech.visible_characters == 0, "interrupted old text is replaced without leftover letters")
	for i in 25:
		writer.advance(0.03)
	await get_tree().process_frame
	await get_tree().process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/art_dialogue_typing.png")
	var layout_before: Rect2 = ui.panel.get_global_rect()
	ui.show_text_button.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	check(ui.panel.get_global_rect() == layout_before, "revealing full message preserves balloon layout")
	# Start the next real step so there is an active reveal to pause.
	cycle.triangle_machine.request_manual_production()
	writer.set_process(true)
	var pause = room.get_node("PauseMenu")
	pause.pause_game()
	var paused_index: int = ui.speech.visible_characters
	var paused_bips: int = bips[0]
	await get_tree().create_timer(0.15, true).timeout
	check(ui.speech.visible_characters == paused_index and bips[0] == paused_bips, "pause freezes reveal and audio triggers")
	pause.resume_game()
	await get_tree().create_timer(0.12).timeout
	check(ui.speech.visible_characters > paused_index, "continue resumes text animation")
	cycle.finish_round()
	check(not ui.visible and not writer.voice.playing, "cycle end hides speech and stops audio")
	print("ART DIALOGUE: %d checks, %d failures" % [checks, failures])
	await get_tree().process_frame
	get_tree().quit(1 if failures else 0)
