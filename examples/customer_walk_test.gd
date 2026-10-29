extends Node2D

const CustomerVisual = preload("res://entities/props/customer_sprite.gd")
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
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1152, 720))
	GameUI.hide()
	var background := ColorRect.new()
	background.color = Color("28221e")
	background.size = Vector2(1152, 720)
	add_child(background)
	for column in range(5):
		var label := Label.new()
		label.text = "Repouso" if column == 0 else "Passo %d" % column
		label.position = Vector2(190 + column * 190, 25)
		add_child(label)
	for variant in range(4):
		var customer := CustomerVisual.new()
		add_child(customer)
		customer._apply_visual(variant)
		var idle := customer.texture
		customer.start_walking(Vector2(-100, 0))
		customer.set_process(false)
		check(customer.walking and customer.flip_h, "left-facing walk")
		var frames := CustomerVisual.WALK_FRAMES[variant]
		check(frames.get_frame_count(&"walk") == 4, "four walking frames")
		var frame_size := frames.get_frame_texture(&"walk", 0).get_size()
		for frame in range(4):
			check(frames.get_frame_texture(&"walk", frame).get_size() == frame_size, "frames share stable canvas and baseline")
			customer.position.x -= customer.pixels_per_frame
			customer._process(0.016)
			check(customer.walk_frame == (frame + 1) % 4, "distance advances animation and loops")
			var before := customer.texture
			customer._process(10.0)
			check(customer.texture == before, "no foot motion without displacement")
		customer.stop_walking()
		check(not customer.walking and not customer.flip_h and customer.texture == idle, "stop restores original idle")
		customer.start_walking(customer.position + Vector2(100, 0))
		check(not customer.flip_h and customer.walk_frame == 0, "right walk resets its phase")
		customer.queue_free()
		var label := Label.new()
		label.text = ["Artesã", "Artesão", "Comerciante", "Agricultora"][variant]
		label.position = Vector2(20, 120 + variant * 150)
		add_child(label)
		for column in range(5):
			var sprite := CustomerVisual.new()
			add_child(sprite)
			sprite.display_height = 110
			sprite._apply_visual(variant)
			if column > 0:
				sprite.walk_frame = column - 1
				sprite._show_walk_frame()
			sprite.position = Vector2(230 + column * 190, 135 + variant * 150)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/customer_walk_frames.png")
	print("CUSTOMER WALK TEST: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
