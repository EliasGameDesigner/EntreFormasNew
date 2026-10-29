@tool
extends Node2D
## One persistent workshop, with a lower passage into the customer room.
const FLOOR := preload("res://data/world/factory_floor_tileset.tres")
const BOUNDS := Rect2(1024, -1728, 1664, 1152)
const FLOOR_TILE_SIZE := 64
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
	var backdrop := Polygon2D.new()
	backdrop.polygon = PackedVector2Array([Vector2(600, -2100), Vector2(3200, -2100), Vector2(3200, -200), Vector2(600, -200)])
	backdrop.color = Color("171414")
	backdrop.z_index = -11
	add_child(backdrop)
	var floor_layer := TileMapLayer.new()
	floor_layer.name = "WoodFloor"
	floor_layer.tile_set = FLOOR
	floor_layer.position = BOUNDS.position
	floor_layer.scale = Vector2.ONE * FLOOR_TILE_SIZE / 627.0
	floor_layer.z_index = -10
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
		_draw_beam(wall)
	# Open doorway centered on the right wall, with a recessed threshold.
	draw_rect(Rect2(2688, -1240, 48, 176), Color("211a17"))
	for y in range(-1232, -1064, 24):
		draw_rect(Rect2(2692, y, 40, 20), Color("62503d"))
	_draw_beam(Rect2(2676, -1252, 60, 16))
	_draw_beam(Rect2(2676, -1068, 60, 16))
	_draw_beam(Rect2(2732, -1252, 12, 200))

func _draw_beam(rect: Rect2) -> void:
	draw_rect(rect, Color("281e18"))
	draw_rect(rect.grow(-3), Color("705038"))
	draw_rect(rect.grow(-7), Color("916544"))
	var vertical := rect.size.y > rect.size.x
	var length := rect.size.y if vertical else rect.size.x
	for d in range(16, int(length), 96):
		var at := rect.position + (Vector2(rect.size.x / 2, d) if vertical else Vector2(d, rect.size.y / 2))
		var strap := Rect2(at - Vector2(12, 5) if vertical else at - Vector2(5, 12), Vector2(24, 10) if vertical else Vector2(10, 24))
		draw_rect(strap, Color("343537"))
		draw_circle(at, 2, Color("c4944d"))
