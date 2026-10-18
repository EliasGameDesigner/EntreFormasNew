extends Node
class_name FirstCycle

signal changed
signal customer_changed
const TRIANGLE = preload("res://data/items/itemTriangulo.tres")
const SQUARE = preload("res://data/items/itemQuadrado.tres")

@export_range(10.0, 600.0) var round_duration: float = 180.0
@export_range(1.0, 180.0) var triangle_patience: float = 30.0
@export_range(1.0, 240.0) var square_patience: float = 75.0
@export_range(0.0, 20.0) var arrival_delay: float = 3.0
@export var triangle_reward: int = 10
@export var square_reward: int = 30
@export var triangle_machine: MachineNode
@export var square_machine: MachineNode
@export var mold_workbench: MoldWorkbench

var running: bool = false
var finished: bool = false
var time_left: float = 0.0
var order_item: ItemData
var order_quantity: int = 0
var order_time_left: float = 0.0
var order_time_total: float = 0.0
var order_reward: int = 0
var customer_number: int = 0
var delivered: int = 0
var missed: int = 0
var score: int = 0
var _arrival_left: float = 0.0

func _ready() -> void:
	add_to_group("first_cycle")
	set_process(false)
	_set_machines_available(false)

func start_round() -> void:
	if running:
		return
	_set_machines_available(false)
	# A retry is a fresh session, including uncollected products.
	if is_instance_valid(mold_workbench):
		mold_workbench.reset_session()
	for child in get_parent().get_children():
		if child is PhysicalItem:
			get_parent().remove_child(child)
			child.queue_free()
	InventoryManager.take_items(InventoryManager.get_all_items())
	InventoryManager.money = 0
	delivered = 0
	missed = 0
	score = 0
	customer_number = 0
	time_left = round_duration
	finished = false
	running = true
	_set_machines_available(true)
	_spawn_order()
	set_process(true)
	changed.emit()

func _process(delta: float) -> void:
	advance_time(delta)

func advance_time(delta: float) -> void:
	if not running or delta <= 0.0:
		return
	time_left = maxf(0.0, time_left - delta)
	if time_left <= 0.0:
		finish_round()
		return
	if order_item != null:
		order_time_left = maxf(0.0, order_time_left - delta)
		if order_time_left <= 0.0:
			missed += 1
			_clear_order()
			GameUI.show_notification("O cliente foi embora. Prepare-se para o próximo!")
	else:
		_arrival_left -= delta
		if _arrival_left <= 0.0:
			_spawn_order()
	changed.emit()

func _spawn_order() -> void:
	customer_number += 1
	# A predictable opening teaches the loop; later orders vary in quantity.
	order_item = TRIANGLE if customer_number % 2 == 1 else SQUARE
	order_quantity = 2 if customer_number <= 2 else randi_range(1, 3)
	order_time_total = triangle_patience if order_item == TRIANGLE else square_patience
	order_time_total *= maxf(1.0, float(order_quantity) / 2.0)
	order_time_left = minf(order_time_total, time_left)
	order_reward = order_quantity * (triangle_reward if order_item == TRIANGLE else square_reward)
	customer_changed.emit()

func _clear_order() -> void:
	order_item = null
	order_quantity = 0
	order_time_left = 0.0
	_arrival_left = arrival_delay
	customer_changed.emit()

func deliver_order() -> bool:
	if not running or order_item == null or order_time_left <= 0.0:
		GameUI.show_notification("Aguarde o próximo cliente.")
		return false
	if get_tree().get_first_node_in_group("modal_repair_ui") != null:
		return false
	if not InventoryManager.take_items({order_item: order_quantity}):
		GameUI.show_notification("Pedido incompleto: colete %d × %s." % [order_quantity, order_item.item_name])
		return false
	delivered += 1
	score += order_reward
	InventoryManager.money += order_reward
	GameUI.show_notification("Pedido entregue! +$%d" % order_reward)
	_clear_order()
	changed.emit()
	return true

func finish_round() -> void:
	if not running:
		return
	running = false
	finished = true
	time_left = 0.0
	set_process(false)
	if order_item != null:
		missed += 1
	_clear_order()
	# Closing a pending assembly refunds it before displaying the result.
	_set_machines_available(false)
	changed.emit()

func _set_machines_available(value: bool) -> void:
	if is_instance_valid(mold_workbench):
		mold_workbench.set_session_active(value)
	for machine in [triangle_machine, square_machine]:
		if is_instance_valid(machine):
			machine.set_manual_available(value)
