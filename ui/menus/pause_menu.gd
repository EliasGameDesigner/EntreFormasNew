extends CanvasLayer
## Always processes so its UI can resume a paused SceneTree; gameplay inherits pause.
@export var cycle: FirstCycle
const STYLE = preload("res://ui/menus/menu_style.gd")
const MAIN_MENU := "res://ui/menus/main_menu.tscn"
var overlay: ColorRect
var pause_button: Button
var resume_button: Button
var main_menu_button: Button
var quit_button: Button
var _owns_pause := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = STYLE.SKIN.create()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_button = Button.new()
	pause_button.text = "Pausar [Esc]"
	pause_button.add_theme_font_size_override("font_size", 24)
	root.add_child(pause_button)
	pause_button.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	pause_button.offset_left = -164
	pause_button.offset_right = -16
	pause_button.offset_top = 16
	pause_button.offset_bottom = 56
	pause_button.pressed.connect(pause_game)
	overlay = ColorRect.new()
	overlay.color = Color(0.035, 0.028, 0.02, 0.88)
	root.add_child(overlay)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	overlay.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := STYLE.card(center, 400)
	STYLE.label(column, "PAUSADO", 44)
	STYLE.label(column, "O expediente está em pausa.", 26)
	resume_button = STYLE.button(column, "Continuar", resume_game)
	main_menu_button = STYLE.button(column, "Voltar ao menu inicial", return_to_main_menu)
	quit_button = STYLE.button(column, "Sair do jogo", quit_game)
	overlay.hide()
	_update_pause_button()

func pause_game() -> void:
	if _owns_pause or get_tree().paused or not cycle.workshop_active():
		return
	_owns_pause = true
	overlay.show()
	overlay.add_to_group("modal_repair_ui")
	get_tree().paused = true
	_update_pause_button()
	resume_button.grab_focus()

func resume_game() -> void:
	if not _owns_pause:
		return
	_owns_pause = false
	overlay.hide()
	overlay.remove_from_group("modal_repair_ui")
	get_tree().paused = false
	resume_button.release_focus()
	_update_pause_button()

func return_to_main_menu() -> void:
	resume_game()
	get_tree().change_scene_to_file(MAIN_MENU)

func quit_game() -> void:
	resume_game()
	get_tree().quit()

func _exit_tree() -> void:
	if _owns_pause:
		get_tree().paused = false

func _update_pause_button() -> void:
	pause_button.visible = cycle.workshop_active() and not _owns_pause and get_tree().get_first_node_in_group("modal_repair_ui") == null

func _process(_delta: float) -> void:
	_update_pause_button()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or event.is_echo():
		return
	if _owns_pause:
		resume_game()
	elif get_tree().get_first_node_in_group("modal_repair_ui") == null and cycle.workshop_active():
		pause_game()
	else:
		return
	get_viewport().set_input_as_handled()
