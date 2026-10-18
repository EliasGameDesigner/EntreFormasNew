extends Node2D

@export var workbench: MoldWorkbench
const TRIANGLE_TEXTURE = preload("res://data/items/triangle_mold_texture.tres")
const SQUARE_TEXTURE = preload("res://data/items/square_mold_texture.tres")

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	workbench.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	visible = workbench.carried_mold != &""
	queue_redraw()

func update_pose(facing: Vector2) -> void:
	# Hold the mold between the hands; behind the torso when facing away.
	scale = Vector2(0.55, 0.4)
	if facing.x != 0:
		position = Vector2(22 * facing.x, 3)
		z_index = 1
	elif facing.y < 0:
		position = Vector2(0, -3)
		z_index = -1
	else:
		position = Vector2(0, 4)
		z_index = 1

func _draw() -> void:
	if workbench.carried_mold == &"square":
		draw_texture_rect(SQUARE_TEXTURE, Rect2(-26, -32.4, 52, 64.8), false)
		return
	if workbench.carried_mold == &"triangle":
		# Compensate for the holding node's nonuniform scale to preserve the art's proportions.
		draw_texture_rect(TRIANGLE_TEXTURE, Rect2(-26, -36, 52, 72), false)
		return
	draw_rect(Rect2(-26, -20, 52, 40), Color("193540"))
	draw_rect(Rect2(-26, -20, 52, 40), Color("77ecdf"), false, 2)
	var vertices: PackedVector2Array
	match workbench.carried_mold:
		&"triangle": vertices = PackedVector2Array([Vector2(-16, 12), Vector2(0, -12), Vector2(16, 12), Vector2(-16, 12)])
		&"square": vertices = PackedVector2Array([Vector2(-12, -12), Vector2(12, -12), Vector2(12, 12), Vector2(-12, 12), Vector2(-12, -12)])
		&"rectangle": vertices = PackedVector2Array([Vector2(-19, -10), Vector2(19, -10), Vector2(19, 10), Vector2(-19, 10), Vector2(-19, -10)])
	if vertices.size() > 1:
		draw_polyline(vertices, Color("b2ffff"), 2, true)
