extends "res://world/tocarMusica.gd"
## The service loop uses the original map. Future unlocks stay in this scene.

@onready var cycle: FirstCycle = $FirstCycle
@onready var customer: Sprite2D = $Customer
var _customer_tween: Tween

func _ready() -> void:
	super._ready()
	cycle.customer_changed.connect(_show_customer)
	customer.hide()
	# Keep the original scenery, but reserve its side activities for later.
	for child in get_children():
		if child is MachinePurchasePoint or child is TaskNode or child is ResourceSpawnPoint:
			child.process_mode = Node.PROCESS_MODE_DISABLED
			_disable_interactions(child)
			if child is TaskNode or child is ResourceSpawnPoint:
				child.hide()
			if child is MachinePurchasePoint:
				child.label.text = child.machine_data.machine_name + "\nDisponível em um próximo ciclo"
	$MaquinaGenerica2.status_label.text = "Máquina de Retângulos\nDisponível em um próximo ciclo"
	$MaquinaGenerica2.modulate = Color(0.6, 0.65, 0.7)
	_disable_interactions($MaquinaGenerica2)
	# These bodies are the original map boundaries, not movable props.
	for child in get_children():
		if child is RigidBody2D:
			child.freeze = true

func _disable_interactions(node: Node) -> void:
	if node is Interactable:
		node.collision_layer = 0
		node.collision_mask = 0
	for child in node.get_children():
		_disable_interactions(child)

func _show_customer() -> void:
	if _customer_tween:
		_customer_tween.kill()
	var destination: Vector2 = $shop_node.position + Vector2(0, -65)
	var entrance: Vector2 = $FactoryLayout/CustomerEntrance.position
	if cycle.order_item == null:
		customer.start_walking(entrance)
		_customer_tween = create_tween()
		_customer_tween.tween_property(customer, "position", entrance, customer.position.distance_to(entrance) / customer.walk_speed)
		_customer_tween.tween_callback(customer.stop_walking)
		_customer_tween.tween_callback(customer.hide)
		return
	customer.show()
	customer.position = entrance
	customer.next_appearance()
	customer.start_walking(destination)
	_customer_tween = create_tween()
	_customer_tween.tween_property(customer, "position", destination, entrance.distance_to(destination) / customer.walk_speed)
	_customer_tween.tween_callback(customer.stop_walking)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		var fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_viewport().set_input_as_handled()
