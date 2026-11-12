extends Node
class_name FirstCycle

signal changed
signal customer_changed
@export var physical_transport: bool = true
var counter_stock: Dictionary = {}
const TRIANGLE = preload("res://data/items/itemTriangulo.tres")
const SQUARE = preload("res://data/items/itemQuadrado.tres")
const RECTANGLE = preload("res://data/items/itemRetangulo.tres")
const PARALLELOGRAM = preload("res://data/items/itemParalelogramo.tres")
@export_range(10.0, 600.0) var third_cycle_duration: float = 240.0
@export_range(1.0, 300.0) var parallelogram_patience: float = 120.0
@export var parallelogram_reward: int = 45
@export var parallelogram_machine: MachineNode
const TRAPEZOID = preload("res://data/items/itemTrapezio.tres")
@export_range(10.0, 600.0) var fourth_cycle_duration: float = 240.0
@export_range(1.0, 300.0) var trapezoid_patience: float = 180.0
@export var trapezoid_reward: int = 70
@export var trapezoid_machine: MachineNode
var cycle_number: int = 1
var cycle_customer_number: int = 0
@export_range(10.0, 600.0) var second_cycle_duration: float = 240.0
@export_range(1.0, 300.0) var rectangle_patience: float = 150.0
@export var rectangle_reward: int = 50
@export var rectangle_machine: MachineNode

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
	cycle_number = 1
	cycle_customer_number = 0
	_set_machines_available(false)
	# A retry is a fresh session, including uncollected products.
	counter_stock.clear()
	var hands = get_tree().get_first_node_in_group("player_hands")
	if hands != null:
		hands.clear()
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

func has_next_cycle() -> bool:
	return finished and cycle_number < 4

func start_next_cycle() -> bool:
	if running or not has_next_cycle():
		return false
	cycle_number += 1
	cycle_customer_number = 0
	finished = false
	running = true
	time_left = {2: second_cycle_duration, 3: third_cycle_duration, 4: fourth_cycle_duration}[cycle_number]
	_set_machines_available(true)
	_spawn_order()
	set_process(true)
	changed.emit()
	return true

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
		elif physical_transport and order_time_total - order_time_left >= 2.0 and counter_stock.get(order_item, 0) >= order_quantity:
			deliver_order()
	else:
		_arrival_left -= delta
		if _arrival_left <= 0.0:
			_spawn_order()
	changed.emit()

func _spawn_order() -> void:
	customer_number += 1
	cycle_customer_number += 1
	# A predictable opening teaches the loop; later orders vary in quantity.
	order_item = TRIANGLE if customer_number % 2 == 1 else SQUARE
	order_quantity = 2 if customer_number <= 2 else randi_range(1, 3)
	order_time_total = triangle_patience if order_item == TRIANGLE else square_patience
	order_time_total *= maxf(1.0, float(order_quantity) / 2.0)
	order_time_left = minf(order_time_total, time_left)
	order_reward = order_quantity * (triangle_reward if order_item == TRIANGLE else square_reward)
	if cycle_number >= 2:
		var products := [RECTANGLE, TRIANGLE, SQUARE]
		if cycle_number >= 3:
			products = [PARALLELOGRAM, TRIANGLE, SQUARE, RECTANGLE]
		if cycle_number >= 4:
			products = [TRAPEZOID, TRIANGLE, SQUARE, RECTANGLE, PARALLELOGRAM]
		order_item = products[(cycle_customer_number - 1) % products.size()]
		order_quantity = 1 if cycle_customer_number == 1 else randi_range(1, 2)
		var patience: float = {TRIANGLE: triangle_patience, SQUARE: square_patience, RECTANGLE: rectangle_patience, PARALLELOGRAM: parallelogram_patience, TRAPEZOID: trapezoid_patience}[order_item]
		order_time_total = patience * order_quantity
		order_time_left = minf(order_time_total, time_left)
		order_reward = order_quantity * int({TRIANGLE: triangle_reward, SQUARE: square_reward, RECTANGLE: rectangle_reward, PARALLELOGRAM: parallelogram_reward, TRAPEZOID: trapezoid_reward}[order_item])
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
	if physical_transport:
		if counter_stock.get(order_item, 0) < order_quantity:
			return false
		counter_stock[order_item] -= order_quantity
	elif not InventoryManager.take_items({order_item: order_quantity}):
		GameUI.show_notification("Pedido incompleto: colete %d × %s." % [order_quantity, order_item.item_name])
		return false
	delivered += 1
	score += order_reward
	InventoryManager.money += order_reward
	GameUI.show_notification("Pedido entregue! +$%d" % order_reward)
	_clear_order()
	changed.emit()
	return true

func deposit_product(product: ItemData) -> bool:
	if not running or not physical_transport or product == null:
		return false
	counter_stock[product] = counter_stock.get(product, 0) + 1
	changed.emit()
	if order_item == product and counter_stock[product] >= order_quantity:
		deliver_order()
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
	var held_mold: StringName = mold_workbench.carried_mold if is_instance_valid(mold_workbench) else &""
	_set_machines_available(false)
	if has_next_cycle() and is_instance_valid(mold_workbench):
		mold_workbench.carried_mold = held_mold
		mold_workbench.changed.emit()
	changed.emit()

func _set_machines_available(value: bool) -> void:
	if is_instance_valid(mold_workbench):
		mold_workbench.available_shapes.assign([&"triangle", &"square", &"rectangle"] if cycle_number >= 2 else [&"triangle", &"square"])
		if cycle_number >= 3:
			mold_workbench.available_shapes.append(&"parallelogram")
		if cycle_number >= 4:
			mold_workbench.available_shapes.append(&"trapezoid")
		mold_workbench.set_session_active(value)
	for machine in [triangle_machine, square_machine]:
		if is_instance_valid(machine):
			machine.set_manual_available(value)
	if is_instance_valid(rectangle_machine):
		var unlocked := cycle_number >= 2
		rectangle_machine.interactable.collision_layer = 1 if unlocked and value else 0
		rectangle_machine.interactable.collision_mask = 1 if unlocked and value else 0
		rectangle_machine.modulate = Color.WHITE if unlocked else Color(0.6, 0.65, 0.7)
		rectangle_machine.set_manual_available(value and unlocked)
		if not unlocked:
			rectangle_machine.status_label.text = "Máquina de Retângulos\nDisponível no ciclo 2"

	if is_instance_valid(parallelogram_machine):
		var unlocked := cycle_number >= 3
		parallelogram_machine.interactable.collision_layer = 1 if unlocked and value else 0
		parallelogram_machine.interactable.collision_mask = 1 if unlocked and value else 0
		parallelogram_machine.modulate = Color.WHITE if unlocked else Color(0.6, 0.65, 0.7)
		parallelogram_machine.set_manual_available(value and unlocked)
		if not unlocked:
			parallelogram_machine.status_label.text = "Máquina de Paralelogramos\nDisponível no ciclo 3"

	if is_instance_valid(trapezoid_machine):
		var unlocked := cycle_number >= 4
		trapezoid_machine.interactable.collision_layer = 1 if unlocked and value else 0
		trapezoid_machine.interactable.collision_mask = 1 if unlocked and value else 0
		trapezoid_machine.modulate = Color.WHITE if unlocked else Color(0.6, 0.65, 0.7)
		trapezoid_machine.set_manual_available(value and unlocked)
		if not unlocked:
			trapezoid_machine.status_label.text = "Máquina de Trapézios\nDisponível no ciclo 4"
