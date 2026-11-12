extends CharacterBody2D
## Coordinates the components; only this node schedules the physics step.
const MovementComponent = preload("res://entities/player/player_movement.gd")
const AnimationComponent = preload("res://entities/player/player_animation.gd")
const InteractionComponent = preload("res://entities/player/player_interaction.gd")

@onready var movement: MovementComponent = $Movement
@onready var animation: AnimationComponent = $Animation
@onready var interaction: InteractionComponent = $Interaction

func controls_blocked() -> bool:
	return get_tree().get_first_node_in_group("modal_repair_ui") != null

func _physics_process(_delta: float) -> void:
	var direction := movement.move(self, controls_blocked())
	animation.update_animation(direction)
	interaction.refresh_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if not controls_blocked():
		interaction.handle_input(event)
