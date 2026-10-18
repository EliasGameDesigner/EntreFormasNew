extends Node2D

@export var workbench: MoldWorkbench

func _ready() -> void:
	workbench.changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	visible = workbench.carried_mold != &""
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-26, -20, 52, 40), Color("193540"))
	draw_rect(Rect2(-26, -20, 52, 40), Color("77ecdf"), false, 2)
	var vertices: PackedVector2Array
	match workbench.carried_mold:
		&"triangle": vertices = PackedVector2Array([Vector2(-16, 12), Vector2(0, -12), Vector2(16, 12), Vector2(-16, 12)])
		&"square": vertices = PackedVector2Array([Vector2(-12, -12), Vector2(12, -12), Vector2(12, 12), Vector2(-12, 12), Vector2(-12, -12)])
		&"rectangle": vertices = PackedVector2Array([Vector2(-19, -10), Vector2(19, -10), Vector2(19, 10), Vector2(-19, 10), Vector2(-19, -10)])
	if vertices.size() > 1:
		draw_polyline(vertices, Color("b2ffff"), 2, true)
