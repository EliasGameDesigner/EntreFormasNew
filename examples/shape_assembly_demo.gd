extends Node2D

## F6: reproducible repair sandbox. Inventory seeding is exclusive to this example.
var square: MachineNode
var rectangle: MachineNode

func _ready() -> void:
	square = load("res://entities/machines/maquina_quadrados.tscn").instantiate()
	rectangle = load("res://entities/machines/maquina_retangulos.tscn").instantiate()
	add_child(square)
	add_child(rectangle)
	square.position = Vector2(400, 330)
	rectangle.position = Vector2(750, 330)
	square.breakage_chance = 0.0
	rectangle.breakage_chance = 0.0
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var toolbar := HBoxContainer.new()
	toolbar.position = Vector2(260, 20)
	canvas.add_child(toolbar)
	for machine in [square, rectangle]:
		var button := Button.new()
		button.text = "Quebrar / reparar: " + machine.machine_data.machine_name
		button.pressed.connect(_open_repair.bind(machine))
		toolbar.add_child(button)
	_open_repair(square)

func _open_repair(machine: MachineNode) -> void:
	if get_tree().get_first_node_in_group("modal_repair_ui"):
		return
	var counts: Dictionary = {}
	for slot in machine.machine_data.repair_assembly.slots:
		var item := slot.piece.inventory_item
		counts[item] = counts.get(item, 0) + 1
	for item in counts:
		var owned: int = InventoryManager.get_all_items().get(item, 0)
		if owned < counts[item]:
			InventoryManager.add_item(item, counts[item] - owned)
	machine.break_machine()
	machine.interactable.start_interaction(null)