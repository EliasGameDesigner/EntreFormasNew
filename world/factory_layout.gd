@tool
extends Node2D
## One persistent workshop, with a lower passage into the customer room.
const FLOOR := preload("res://data/world/factory_floor_tileset.tres")
const WALL_TEXTURE := preload("res://assets/textures/props/factory_wall_tiles_v1.png")
const TERRAIN_TEXTURE := preload("res://assets/textures/props/exterior_terrain_tiles_v1.png")
const PROPS_TEXTURE := preload("res://assets/textures/props/exterior_props_v1.png")
const TERRAIN_SHADER := preload("res://world/exterior_terrain.gdshader")
const ALPHA_SHADER := preload("res://entities/player/sprite_alpha.gdshader")
const BOUNDS := Rect2(1024, -1728, 1664, 1152)
const FLOOR_TILE_SIZE := 64
const WALL_TILE_SIZE := 64
@export var show_exterior: bool = false:
	set(value):
		show_exterior = value
		for node_name in ["ExteriorTerrain", "ExteriorProps"]:
			var node := get_node_or_null(NodePath(node_name))
			if node != null:
				node.visible = value
const WALLS: Array[Rect2] = [
	Rect2(996, -1756, 1720, 28),
	Rect2(996, -576, 1720, 28),
	Rect2(996, -1728, 28, 1152),
	Rect2(2688, -1728, 28, 488),
	Rect2(2688, -1064, 28, 488),
	Rect2(2162, -1728, 28, 704),
	Rect2(2162, -800, 28, 224),
]

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var interior_backdrop := Polygon2D.new()
	interior_backdrop.name = "InteriorBackdrop"
	interior_backdrop.polygon = PackedVector2Array([Vector2(-4096, -4096), Vector2(4096, -4096), Vector2(4096, 4096), Vector2(-4096, 4096)])
	interior_backdrop.color = Color.BLACK
	interior_backdrop.z_index = -12
	add_child(interior_backdrop)
	var backdrop := Polygon2D.new()
	backdrop.polygon = PackedVector2Array([Vector2(600, -2100), Vector2(3200, -2100), Vector2(3200, -200), Vector2(600, -200)])
	backdrop.name = "ExteriorTerrain"
	backdrop.visible = show_exterior
	var terrain_material := ShaderMaterial.new()
	terrain_material.shader = TERRAIN_SHADER
	terrain_material.set_shader_parameter("terrain_sheet", TERRAIN_TEXTURE)
	backdrop.material = terrain_material
	backdrop.z_index = -11
	add_child(backdrop)
	_add_exterior_props()
	var floor_layer := TileMapLayer.new()
	floor_layer.name = "WoodFloor"
	floor_layer.tile_set = FLOOR
	floor_layer.position = BOUNDS.position
	floor_layer.scale = Vector2.ONE * FLOOR_TILE_SIZE / 627.0
	floor_layer.z_index = -10
	# Midtone floor: keep the lighter artwork without competing with interactables.
	floor_layer.self_modulate = Color(0.78, 0.80, 0.83)
	for y in range(int(BOUNDS.size.y / FLOOR_TILE_SIZE)):
		for x in range(int(BOUNDS.size.x / FLOOR_TILE_SIZE)):
			var variant := posmod(x * 17 + y * 31 + x * y * 7, 4)
			floor_layer.set_cell(Vector2i(x, y), 0, Vector2i(variant % 2, variant / 2))
	add_child(floor_layer)
	if not Engine.is_editor_hint():
		for wall in WALLS:
			_add_wall_collision(wall)
		# Customers are visual sprites; the threshold keeps the player inside.
		_add_wall_collision(Rect2(2716, -1240, 24, 176))
	queue_redraw()

func _add_wall_collision(rect: Rect2) -> void:
	var body := StaticBody2D.new()
	body.position = rect.get_center()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _draw() -> void:
	for wall in WALLS:
		var vertical := wall.size.y > wall.size.x
		if not vertical and wall.position.y < BOUNDS.position.y:
			# Only north-facing walls expose their full masonry face.
			var extra := (WALL_TILE_SIZE - wall.size.y) / 2.0
			var visual := wall.grow_individual(0, extra, 0, extra)
			draw_rect(visual.grow(3), Color(0, 0, 0, 0.22))
			_draw_wall(visual)
		else:
			_draw_cutaway_wall(wall)
	# Small timber feet cap corners, the partition and doorway ends.
	for point in [Vector2(1010, -1720), Vector2(2176, -1720), Vector2(2702, -1720), Vector2(1010, -562), Vector2(2176, -562), Vector2(2702, -562), Vector2(2176, -1024), Vector2(2176, -800)]:
		_draw_wall_post(point)
	# A shallow stone threshold opens into the black interior cutaway.
	for y in range(-1240, -1064, 44):
		_draw_wall_tile(Rect2(2688, y, 48, 44), Vector2i(1, 1))
	_draw_wall(Rect2(2688, -1246, 48, 12))
	_draw_wall(Rect2(2688, -1070, 48, 12))
	_draw_wall_post(Vector2(2702, -1240))
	_draw_wall_post(Vector2(2702, -1064))

func _draw_cutaway_wall(wall: Rect2) -> void:
	var vertical := wall.size.y > wall.size.x
	# Keep a narrow dark plinth beneath the wooden top surface.
	draw_rect(wall, Color("302117"))
	var cap := wall.grow_individual(-5, 0, -5, 0) if vertical else wall.grow_individual(0, -5, 0, -5)
	_draw_wall(cap)
	draw_rect(cap, Color("4d3421"), false, 1)

func _draw_wall_post(center: Vector2) -> void:
	var base := Rect2(center - Vector2(16, 14), Vector2(32, 28))
	draw_rect(base, Color("241a13"))
	# A square crop of the timber cap gives the foot a top surface, not a stone face.
	draw_texture_rect_region(WALL_TEXTURE, base.grow(-3), Rect2(16, 8, 128, 128))
	draw_rect(base.grow(-3), Color("785033"), false, 1)

func _draw_wall(rect: Rect2) -> void:
	var vertical := rect.size.y > rect.size.x
	var length := rect.size.y if vertical else rect.size.x
	var source_size := Vector2(WALL_TEXTURE.get_size()) / 2.0
	for offset in range(0, int(length), WALL_TILE_SIZE):
		var segment := minf(WALL_TILE_SIZE, length - offset)
		var target := Rect2(rect.position + Vector2(0, offset), Vector2(rect.size.x, segment)) if vertical else Rect2(rect.position + Vector2(offset, 0), Vector2(segment, rect.size.y))
		var source := Rect2(Vector2(source_size.x, 0) if vertical else Vector2.ZERO, source_size)
		# Crop partial cells and narrow jambs at uniform scale instead of stretching them.
		if vertical:
			source.size.x *= rect.size.x / WALL_TILE_SIZE
			source.position.x += (source_size.x - source.size.x) / 2.0
			source.size.y *= segment / WALL_TILE_SIZE
		else:
			source.size.x *= segment / WALL_TILE_SIZE
			source.size.y *= rect.size.y / WALL_TILE_SIZE
		draw_texture_rect_region(WALL_TEXTURE, target, source)

func _draw_wall_tile(target: Rect2, cell: Vector2i) -> void:
	var source_size := Vector2(WALL_TEXTURE.get_size()) / 2.0
	draw_texture_rect_region(WALL_TEXTURE, target, Rect2(Vector2(cell) * source_size, target.size * source_size / WALL_TILE_SIZE))

func _add_exterior_props() -> void:
	var dressing := Node2D.new()
	dressing.name = "ExteriorProps"
	dressing.visible = show_exterior
	dressing.z_index = -9
	add_child(dressing)
	var placements := [
		Vector3(920, -1560, 1), Vector3(915, -1240, 0), Vector3(920, -780, 2),
		Vector3(1200, -1840, 0), Vector3(1800, -1830, 3), Vector3(2330, -1840, 2),
		Vector3(2820, -1350, 0), Vector3(2825, -1010, 1), Vector3(2860, -1600, 2),
		Vector3(2815, -640, 0), Vector3(1500, -470, 0), Vector3(2200, -470, 1),
		Vector3(2980, -920, 3), Vector3(3030, -1430, 1), Vector3(800, -1040, 3),
	]
	var material := ShaderMaterial.new()
	material.shader = ALPHA_SHADER
	var cell_size := Vector2(PROPS_TEXTURE.get_size()) / 2.0
	for entry in placements:
		var sprite := Sprite2D.new()
		var texture := AtlasTexture.new()
		var variant := int(entry.z)
		texture.atlas = PROPS_TEXTURE
		texture.region = Rect2(Vector2(variant % 2, variant / 2) * cell_size, cell_size)
		texture.filter_clip = true
		sprite.texture = texture
		sprite.material = material
		sprite.position = Vector2(entry.x, entry.y)
		sprite.scale = Vector2.ONE * 0.16
		dressing.add_child(sprite)
