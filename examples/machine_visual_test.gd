extends Node2D

const SCENES = [preload("res://entities/machines/maquina_triangulos.tscn"), preload("res://entities/machines/maquina_quadrados.tscn"), preload("res://entities/machines/maquina_retangulos.tscn"), preload("res://entities/machines/maquina_paralelogramos.tscn"), preload("res://entities/machines/maquina_trapezios.tscn")]
const NAMES = ["Triângulo", "Quadrado", "Retângulo", "Paralelogramo", "Trapézio"]
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
	GameUI.hide()
	for i in range(SCENES.size()):
		var machine: MachineNode = SCENES[i].instantiate()
		machine.machine_data = machine.machine_data.duplicate()
		machine.machine_data.can_break = true
		machine.current_state = MachineNode.MachineState.WORKING
		machine.manual_production = true
		machine.position = Vector2(-10000, -10000)
		machine.production_time = 10
		machine.breakage_chance = 0
		machine.get_node("WorkingAudioPlayer").volume_db = -80
		add_child(machine)
		check(machine.animated_sprite.animation == &"idle", "manual machine starts idle")
		check(machine.animated_sprite.sprite_frames == machine.machine_data.visual_frames, "machine uses its own artwork")
		var frames := machine.machine_data.visual_frames
		for animation in [&"idle", &"funcionando", &"quebrada"]:
			check(frames.has_animation(animation), "required animation exists")
			for frame in range(frames.get_frame_count(animation)):
				check(frames.get_frame_texture(animation, frame).get_size() == Vector2(700, 700), "frames share aligned canvas size")
		machine.manual_production = false
		machine.start_production()
		check(machine.animated_sprite.animation == &"funcionando" and machine.animated_sprite.is_playing(), "production animates")
		await get_tree().create_timer(0.4).timeout
		check(machine.animated_sprite.frame == 1, "working animation advances")
		machine.stop_production()
		check(machine.animated_sprite.animation == &"idle", "stopping returns to idle")
		machine.break_machine()
		check(machine.animated_sprite.animation == &"quebrada", "broken state survives stop_production")
		machine.repair_machine()
		check(machine.animated_sprite.animation == &"funcionando", "repair resumes production animation")
		machine.stop_production()
		for row in range(3):
			var sprite := AnimatedSprite2D.new()
			sprite.sprite_frames = frames
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.scale = Vector2.ONE * machine.machine_data.visual_scale * 0.7
			sprite.position = Vector2(126 + i * 225, 190 + row * 215 - 330 * sprite.scale.y)
			add_child(sprite)
			sprite.play(["idle", "funcionando", "quebrada"][row])
			var label := Label.new()
			label.text = NAMES[i] + " • " + ["Repouso", "Produzindo", "Quebrada"][row]
			label.add_theme_font_size_override("font_size", 14)
			label.position = Vector2(32 + i * 225, 196 + row * 215)
			add_child(label)
		machine.queue_free()
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/machine_variants.png")
	print("MACHINE VISUAL TEST: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
