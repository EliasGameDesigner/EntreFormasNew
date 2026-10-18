extends Node2D
class_name ShopNode

@export var order_counter: bool = false

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interaction_started.connect(_on_interaction_started)

func _on_interaction_started(_body: Node2D) -> void:
	interactable.stop_interaction()
	if order_counter:
		var service := get_tree().get_first_node_in_group("first_cycle")
		if service:
			service.deliver_order()
		return
	sell_all_inventory()

func sell_all_inventory() -> void:
	var inventory_items = InventoryManager.get_all_items()
	var total_earned: int = 0
	
	for item in inventory_items:
		if item.price > 0:
			var quantity = inventory_items[item]
			var items_value = item.price * quantity
			total_earned += items_value
			InventoryManager.remove_item(item, quantity)
			
	if total_earned > 0:
		InventoryManager.money += total_earned
		GameUI.show_notification("Vendeu produtos por: +$" + str(total_earned))
	else:
		GameUI.show_notification("Nenhum item de valor para vender!")
