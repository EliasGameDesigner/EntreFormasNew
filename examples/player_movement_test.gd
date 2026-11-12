extends SceneTree

var failures := 0
var checks := 0

func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func press(player: Node, action: StringName, held: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = held
	if held:
		Input.action_press(action)
	else:
		Input.action_release(action)
	player.movement._input(event)

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var room = load("res://world/first_cycle.tscn").instantiate()
	root.add_child(room)
	room.get_node("HUD")._start()
	room.get_node("FirstCycle").set_process(false)
	var player = room.get_node("CharacterBody2D")
	check(not player.has_node("TopDownControler2D"), "plugin controller removed from player scene")
	check(player.has_node("Movement") and player.has_node("Animation") and player.has_node("Interaction"), "player owns three separate components")
	check(player.movement.speed == 210.0, "scene uses reduced walking speed")
	for first in player.movement.MOVE_ACTIONS:
		for second in player.movement.MOVE_ACTIONS:
			if first == second:
				continue
			press(player, first, true)
			press(player, second, true)
			var expected: Vector2 = player.movement.MOVE_DIRECTIONS[player.movement.MOVE_ACTIONS.find(second)]
			check(player.movement.get_movement_direction() == expected, "last pressed wins for every direction pair")
			press(player, second, false)
			check(player.movement.get_movement_direction() == player.movement.MOVE_DIRECTIONS[player.movement.MOVE_ACTIONS.find(first)], "release resumes previously held key")
			press(player, first, false)
			check(player.movement.get_movement_direction() == Vector2.ZERO, "release all stops movement")
	press(player, &"right", true)
	press(player, &"up", true)
	await physics_frame
	await physics_frame
	check(player.velocity == Vector2(0, -210), "actual physics movement is cardinal at reduced speed")
	check(player.animation.facing == Vector2.UP, "animation faces active direction")
	var modal := Node.new()
	modal.add_to_group("modal_repair_ui")
	root.add_child(modal)
	await physics_frame
	await physics_frame
	check(player.velocity == Vector2.ZERO, "modal still blocks movement")
	modal.queue_free()
	Input.action_release(&"up")
	Input.action_release(&"right")
	check(player.movement.get_movement_direction() == Vector2.ZERO, "polling removes stale held keys")
	print("PLAYER MOVEMENT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
