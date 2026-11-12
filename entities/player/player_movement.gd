extends Node
## Cardinal input priority and physical movement; no UI or animation logic.
@export var speed: float = 210.0
const MOVE_ACTIONS: Array[StringName] = [&"left", &"right", &"up", &"down"]
const MOVE_DIRECTIONS: Array[Vector2] = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
var _held_directions: Array[StringName] = []

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	for action in MOVE_ACTIONS:
		if event.is_action_pressed(action):
			_held_directions.erase(action)
			_held_directions.append(action)
		elif event.is_action_released(action):
			_held_directions.erase(action)

func get_movement_direction() -> Vector2:
	# Poll too, so focus loss or programmatic input cannot leave a stuck key.
	for action in MOVE_ACTIONS:
		if not Input.is_action_pressed(action):
			_held_directions.erase(action)
		elif not _held_directions.has(action):
			_held_directions.append(action)
	if _held_directions.is_empty():
		return Vector2.ZERO
	return MOVE_DIRECTIONS[MOVE_ACTIONS.find(_held_directions.back())]

func move(body: CharacterBody2D, blocked: bool) -> Vector2:
	if blocked:
		body.velocity = Vector2.ZERO
		return Vector2.ZERO
	var direction := get_movement_direction()
	body.velocity = direction * speed
	body.move_and_slide()
	for i in range(body.get_slide_collision_count()):
		var collider := body.get_slide_collision(i).get_collider()
		if collider is RigidBody2D and collider.is_in_group("ground_carryables") and not collider.freeze:
			var remaining_speed := maxf(0.0, speed - collider.linear_velocity.dot(direction))
			collider.apply_central_impulse(direction * remaining_speed * collider.mass * 0.35)
	return direction
