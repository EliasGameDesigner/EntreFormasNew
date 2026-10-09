extends Node2D
class_name MachinePurchasePoint

signal machine_purchased(machine: MachineNode)
@export var machine_scene: PackedScene
@export var machine_data: MachineData
@export var unlock_after_repair: MachineData
var purchased_machine: MachineNode
var purchased: bool = false
var _refresh_elapsed: float = 0.0

@onready var interactable: Interactable = $Interactable
@onready var label: Label = $Label

func _ready() -> void:
	interactable.interaction_started.connect(_on_interaction_started)
	InventoryManager.money_changed.connect(_on_money_changed)
	refresh_display()

func _process(delta: float) -> void:
	# Covers machines bought later without a global progression singleton.
	if purchased:
		return
	_refresh_elapsed += delta
	if _refresh_elapsed >= 0.5:
		_refresh_elapsed = 0.0
		refresh_display()

func is_unlocked() -> bool:
	if unlock_after_repair == null:
		return true
	for node in get_tree().get_nodes_in_group("machines"):
		if node is MachineNode and node.machine_data and node.was_repaired:
			if node.machine_data.produced_item == unlock_after_repair.produced_item:
				return true
	return false

func _on_money_changed(_money: int) -> void:
	refresh_display()

func refresh_display() -> void:
	if purchased or machine_data == null:
		return
	var instruction := "Mouse1: comprar por $%d" % machine_data.cost
	if not is_unlocked():
		instruction = "Bloqueada: conserte\n" + unlock_after_repair.machine_name
	elif InventoryManager.money < machine_data.cost:
		instruction = "Compra: $%d • Saldo: $%d" % [machine_data.cost, InventoryManager.money]
	label.text = machine_data.machine_name + "\n" + instruction

func _on_interaction_started(_body: Node2D) -> void:
	interactable.stop_interaction()
	try_purchase()

func try_purchase() -> bool:
	if purchased or machine_data == null or machine_scene == null:
		return false
	if get_tree().get_first_node_in_group("modal_repair_ui") != null:
		return false
	if not is_unlocked():
		GameUI.show_notification("Conserte " + unlock_after_repair.machine_name + " para desbloquear.")
		return false
	if InventoryManager.money < machine_data.cost:
		GameUI.show_notification("Saldo insuficiente. Venda peças na loja para comprar esta máquina.")
		return false
	var instance := machine_scene.instantiate()
	if not instance is MachineNode:
		instance.free()
		return false
	purchased = true
	purchased_machine = instance
	purchased_machine.machine_data = machine_data
	purchased_machine.current_state = MachineNode.MachineState.WORKING
	purchased_machine.transform = transform
	InventoryManager.money -= machine_data.cost
	get_parent().add_child(purchased_machine)
	# Keep this point as the owner of the purchase state, with no active hit area.
	hide()
	interactable.set_deferred("monitorable", false)
	interactable.set_deferred("monitoring", false)
	$Interactable/CollisionShape2D.set_deferred("disabled", true)
	machine_purchased.emit(purchased_machine)
	GameUI.show_notification(machine_data.machine_name + " comprada e funcionando!")
	return true
