extends Node2D

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
	var bench = preload("res://entities/props/mold_workbench.tscn").instantiate()
	add_child(bench)
	bench.hide()
	bench.set_session_active(true)
	var player = preload("res://entities/player/player.tscn").instantiate()
	player.get_node("TopDownControler2D").process_mode = Node.PROCESS_MODE_DISABLED
	var mold := Node2D.new()
	mold.name = "CarriedMold"
	mold.set_script(preload("res://entities/player/carried_mold.gd"))
	mold.workbench = bench
	player.add_child(mold)
	add_child(player)
	for camera in player.find_children("*", "Camera2D", true, false):
		camera.enabled = false
	player.set_physics_process(false)
	player.hide()
	var directions := [Vector2.DOWN, Vector2.UP, Vector2.RIGHT, Vector2.LEFT]
	var suffixes := ["", "_Back", "_Right", "_Right"]
	for carry in range(2):
		bench.carried_mold = &"square" if carry else &""
		bench.changed.emit()
		for i in range(4):
			player.update_animation(directions[i])
			var sprite: AnimatedSprite2D = player.animated_sprite
			var expected: String = ("Carry" if carry else "Walk") + suffixes[i]
			check(sprite.animation == expected, "direction and carrying select correct walk")
			check(sprite.flip_h == (i == 3), "only left-facing sprite is mirrored")
			check(sprite.sprite_frames.get_frame_count(sprite.animation) == 4, "four walk frames")
			player.update_animation(Vector2.ZERO)
			check(sprite.animation == expected + "_Idle", "idle retains facing and carrying pose")
			var rest := sprite.sprite_frames.get_frame_texture(sprite.animation, 0) as AtlasTexture
			check(rest.atlas.resource_path.ends_with("character_idle.png"), "idle uses feet-planted artwork instead of a walk frame")
			check(sprite.material.get_shader_parameter("idle_breathing"), "idle enables subtle breathing")
			if carry:
				check((mold.z_index < 0) == (i == 1), "mold behind body only when facing up")
			var anchor := Node2D.new()
			anchor.position = Vector2(180 + i * 260, 210 + carry * 300)
			anchor.scale = Vector2(2.3, 2.3)
			add_child(anchor)
			var preview := sprite.duplicate() as AnimatedSprite2D
			anchor.add_child(preview)
			preview.play(expected + "_Idle")
			if carry:
				var held = mold.duplicate()
				anchor.add_child(held)
			var title := Label.new()
			title.text = "Idle com molde" if carry else "Idle"
			title.position = anchor.position + Vector2(-50, 110)
			add_child(title)
	player.footstep_player.stop()
	if DisplayServer.get_name() != "headless":
		await get_tree().create_timer(0.4).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://worker_preview.tmp.png")
	check(bench.consume_for(FirstCycle.SQUARE), "inserting square consumes its mold")
	player.update_animation(Vector2.ZERO)
	check(player.animated_sprite.animation == &"Walk_Right_Idle" and not mold.visible, "insertion restores empty hands while retaining facing")
	print("Worker animation checks: %d, failures: %d" % [checks, failures])
	get_tree().quit(1 if failures else 0)
