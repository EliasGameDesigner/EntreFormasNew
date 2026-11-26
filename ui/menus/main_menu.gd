extends Control
const GAME_SCENE := "res://world/play.tscn"
const STYLE = preload("res://ui/menus/menu_style.gd")
var play_button: Button
var quit_button: Button
var _opening := false

func _ready() -> void:
	theme = STYLE.SKIN.create()
	GameUI.hide()
	GameUI.notification_timer.stop()
	GameUI.notification_label.text = ""
	AudioManager.stop_ambient()
	var background := ColorRect.new()
	background.color = Color("131510")
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var column := STYLE.card(center, 560)
	var art := TextureRect.new()
	art.texture = preload("res://assets/textures/characters/art_top_hat_v1.png")
	art.custom_minimum_size = Vector2(0, 104)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	column.add_child(art)
	STYLE.label(column, "FANTÁSTICA\nFÁBRICA DE FORMAS", 48)
	STYLE.label(column, "Monte, fabrique e entregue.", 28)
	var shapes := HBoxContainer.new()
	shapes.alignment = BoxContainer.ALIGNMENT_CENTER
	shapes.add_theme_constant_override("separation", 18)
	column.add_child(shapes)
	for shape in ["triangle", "square", "rectangle", "parallelogram", "trapezoid"]:
		var icon := TextureRect.new()
		icon.texture = load("res://data/items/%s_part_texture.tres" % shape)
		icon.custom_minimum_size = Vector2(36, 36)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		shapes.add_child(icon)
	play_button = STYLE.button(column, "Jogar", start_game)
	quit_button = STYLE.button(column, "Sair do jogo", quit_game)
	STYLE.label(column, "Com Art, sua cartola instrutora", 22)
	play_button.grab_focus()

func start_game() -> void:
	if _opening:
		return
	_opening = true
	play_button.disabled = true
	var error := get_tree().change_scene_to_file(GAME_SCENE)
	if error != OK:
		_opening = false
		play_button.disabled = false
		push_error("Não foi possível abrir a fábrica: %s" % error_string(error))

func quit_game() -> void:
	get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_viewport().set_input_as_handled()
