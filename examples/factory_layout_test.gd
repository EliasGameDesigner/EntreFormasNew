extends Node2D

var checks := 0
var failures := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func blocked(from: Vector2, to: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(from, to, 1)
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _ready() -> void:
	run.call_deferred()

func run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1152, 720))
	var room = preload("res://world/first_cycle.tscn").instantiate()
	add_child(room)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var layout = room.get_node("FactoryLayout")
	var floor_layer: TileMapLayer = layout.get_node("WoodFloor")
	check(floor_layer.get_used_cells().size() == 468, "floor covers all 26 by 18 smaller tiles")
	check(floor_layer.tile_set.get_source(0).get_tiles_count() == 4, "four editable atlas tiles")
	check(not room.get_node("TileMapLayer").collision_enabled, "legacy map collisions disabled")
	check(blocked(Vector2(2100, -1400), Vector2(2250, -1400)), "partition blocks direct crossing")
	check(not blocked(Vector2(2070, -912), Vector2(2290, -912)), "lower passage stays open")
	check(blocked(Vector2(1100, -1200), Vector2(950, -1200)), "left perimeter blocks escape")
	check(blocked(Vector2(2500, -650), Vector2(2500, -500)), "bottom perimeter blocks escape")
	check(blocked(Vector2(2650, -1152), Vector2(2770, -1152)), "outer threshold keeps player inside")
	var counter: Node2D = room.get_node("shop_node")
	var entrance: Marker2D = layout.get_node("CustomerEntrance")
	check(entrance.position.y == -1152, "entrance centered on right wall")
	check(counter.position.y - 65 == entrance.position.y, "customer route aligns counter with entrance")
	var cycle: FirstCycle = room.get_node("FirstCycle")
	cycle.start_round()
	cycle.set_process(false)
	check(room.get_node("Customer").position == entrance.position, "customer enters through door")
	await get_tree().create_timer(1.8).timeout
	check(not room.get_node("Customer").walking, "customer reaches counter and stops")
	room.get_node("HUD").hide()
	GameUI.hide()
	room.get_node("CharacterBody2D/FollowCamera").enabled = false
	var overview := Camera2D.new()
	overview.position = Vector2(1872, -1152)
	overview.zoom = Vector2.ONE * 0.55
	add_child(overview)
	overview.make_current()
	overview.force_update_scroll()
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/images/factory_layout.png")
	print("FACTORY LAYOUT TEST: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures else 0)
