extends Node2D
class_name ShopNode

@export var order_counter: bool = false

@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	interactable.interaction_started.connect(_on_interaction_started)
	_connect_counter.call_deferred()

func _connect_counter() -> void:
	var cycle = get_tree().get_first_node_in_group("first_cycle")
	if order_counter and cycle != null:
		var stacks := Node2D.new()
		stacks.name = "Stacks"
		stacks.z_index = 1
		stacks.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(stacks)
		stacks.draw.connect(_draw_stacks.bind(stacks))
		cycle.changed.connect(stacks.queue_redraw)

func _on_interaction_started(_body: Node2D) -> void:
	interactable.stop_interaction()
	if order_counter:
		var service := get_tree().get_first_node_in_group("first_cycle")
		if service:
			if service.physical_transport:
				var hands = _body.get_node_or_null("Hands")
				if hands != null and hands.product != null:
					if service.deposit_product(hands.product):
						hands.clear()
				else:
					GameUI.show_notification("Traga uma peça produzida nas mãos para depositar.")
			else:
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

func _draw_stacks(canvas: Node2D) -> void:
	var cycle = get_tree().get_first_node_in_group("first_cycle")
	if cycle == null or not cycle.physical_transport:
		return
	var column := 0
	for item in cycle.counter_stock:
		var count: int = cycle.counter_stock[item]
		if count <= 0:
			continue
		var size: Vector2 = item.icon.get_size()
		size = size / maxf(size.x, size.y) * 32
		var x := -28.0 + column * 42.0
		for i in range(mini(count, 10)):
			canvas.draw_texture_rect(item.icon, Rect2(Vector2(x, -26 - i * 7) - size / 2, size), false)
		canvas.draw_string(ThemeDB.fallback_font, Vector2(x - 10, -40 - mini(count, 10) * 7), str(count), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
		column += 1
