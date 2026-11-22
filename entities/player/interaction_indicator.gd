extends Sprite2D
## Fixed-size badge above the player's head; presentation only.
enum Kind { NONE, PICKUP, INTERACT }
const GLOVE = preload("res://assets/textures/ui/interaction_glove.svg")
const EXCLAMATION = preload("res://assets/textures/ui/interaction_exclamation.svg")
var kind: Kind = Kind.NONE

func _ready() -> void:
	hide()

func set_kind(value: Kind) -> void:
	if kind == value:
		return
	kind = value
	visible = kind != Kind.NONE
	texture = GLOVE if kind == Kind.PICKUP else EXCLAMATION
