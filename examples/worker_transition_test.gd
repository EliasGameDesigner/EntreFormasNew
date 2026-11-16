extends Node2D
## Rendered regression: texture resolution changes must not blend incompatible scales.
signal pose_applied
var player
var bench
var pending := false
var direction := Vector2.ZERO
var carrying := false
var checks := 0
var failures := 0
func _ready() -> void:
	run.call_deferred()
func _physics_process(_delta: float) -> void:
	if pending:
		pending = false
		bench.carried_mold = &"square" if carrying else &""
		bench.changed.emit()
		player.animation.update_animation(direction)
		pose_applied.emit()
func run() -> void:
	if DisplayServer.get_name() == "headless":
		print("WORKER TRANSITIONS: requires graphical rendering")
		get_tree().quit()
		return
	Engine.physics_ticks_per_second = 10
	Engine.max_fps = 120
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	bench = preload("res://entities/props/mold_workbench.tscn").instantiate()
	add_child(bench)
	bench.hide()
	bench.set_session_active(true)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.world_2d = World2D.new()
	add_child(viewport)
	player = preload("res://entities/player/player.tscn").instantiate()
	var mold := Node2D.new()
	mold.name = "CarriedMold"
	mold.set_script(preload("res://entities/player/carried_mold.gd"))
	mold.workbench = bench
	player.add_child(mold)
	player.position = Vector2(128, 128)
	viewport.add_child(player)
	player.set_physics_process(false)
	player.get_node("InteractionLabel").hide()
	player.reset_physics_interpolation()
	var largest := 0
	var smallest := 256
	for carry in [false, true, false]:
		for next_direction in [Vector2.DOWN, Vector2.ZERO, Vector2.UP, Vector2.ZERO, Vector2.RIGHT, Vector2.ZERO, Vector2.LEFT, Vector2.DOWN]:
			carrying = carry
			direction = next_direction
			pending = true
			await pose_applied
			for frame in range(4):
				await RenderingServer.frame_post_draw
				var height: int = viewport.get_texture().get_image().get_used_rect().size.y
				checks += 1
				largest = maxi(largest, height)
				smallest = mini(smallest, height)
				if height < 70 or height > 90:
					failures += 1
					push_error("Rendered character changed size during transition: %d pixels" % height)
	print("WORKER TRANSITIONS: %d checks, %d failures, rendered height %d..%d" % [checks, failures, smallest, largest])
	get_tree().quit(1 if failures else 0)
