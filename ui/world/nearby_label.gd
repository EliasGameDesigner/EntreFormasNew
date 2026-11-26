extends Node
## World-space label visibility, independent of production and interaction eligibility.
@export var label: Label
@export var target: Node2D
@export_range(32.0, 500.0, 8.0) var show_distance: float = 160.0
@export_range(0.0, 100.0, 4.0) var exit_margin: float = 24.0
var _near := false

func _ready() -> void:
	label.hide()

func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null or get_tree().get_first_node_in_group("modal_repair_ui") != null:
		_near = false
		label.hide()
		return
	var radius := show_distance + (exit_margin if _near else 0.0)
	_near = player.global_position.distance_squared_to(target.global_position) <= radius * radius
	label.visible = _near
