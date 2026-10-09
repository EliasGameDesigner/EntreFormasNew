extends Node2D

## F6: repair sandbox. Inventory seeding happens only in this example.
@export_enum("Quadrado", "Retângulo", "Paralelogramo", "Trapézio") var initial_machine: int = 3
const SCENES = [
	"res://entities/machines/maquina_quadrados.tscn",
	"res://entities/machines/maquina_retangulos.tscn",
	"res://entities/machines/maquina_paralelogramos.tscn",
	"res://entities/machines/maquina_trapezios.tscn",
]

func _ready() -> void:
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var toolbar := GridContainer.new()
	toolbar.columns = 2
	toolbar.position = Vector2(220, 20)
	canvas.add_child(toolbar)
	var machines: Array[MachineNode] = []
	for i in range(SCENES.size()):
		var machine: MachineNode = load(SCENES[i]).instantiate()
		machine.position = Vector2(220 + i * 230, 350)
		machine.breakage_chance = 0.0
		add_child(machine)
		machines.append(machine)
		var button := Button.new()
		button.text = "Reparar: " + machine.machine_data.repair_assembly.title
		button.custom_minimum_size = Vector2(330, 36)
		button.pressed.connect(_open_repair.bind(machine))
		toolbar.add_child(button)
	_open_repair(machines[clampi(initial_machine, 0, machines.size() - 1)])

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