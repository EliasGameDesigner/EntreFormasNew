extends Node
# NOTA: Configure este script como Autoload com o nome 'InventoryManager' nas configurações do projeto.

signal inventory_changed
signal money_changed(new_amount: int)

var _items: Dictionary = {} # Chave: ItemData, Valor: int (quantidade)
var money: int = 0:
	set(value):
		money = value
		money_changed.emit(money)

func add_item(item: ItemData, amount: int = 1) -> void:
	if item == null or amount <= 0: return
	
	if _items.has(item):
		_items[item] += amount
	else:
		_items[item] = amount
		
	inventory_changed.emit()
	print("Inventário: ", amount, "x ", item.item_name, " adicionado. Total: ", _items[item])

func remove_item(item: ItemData, amount: int = 1) -> bool:
	if item == null or amount <= 0: return false
	
	if _items.has(item) and _items[item] >= amount:
		_items[item] -= amount
		if _items[item] <= 0:
			_items.erase(item)
		inventory_changed.emit()
		return true
		
	return false

func has_item(item: ItemData, amount: int = 1) -> bool:
	if item == null: return false
	return _items.has(item) and _items[item] >= amount

# Retorna uma cópia para evitar que outros scripts alterem o dicionário original diretamente
func get_all_items() -> Dictionary:
	return _items.duplicate()

## Validate the entire transaction before notifying any machine or UI.
func take_items(requirements: Dictionary) -> bool:
	for item in requirements:
		if not item is ItemData or requirements[item] <= 0 or not has_item(item, requirements[item]):
			return false
	for item in requirements:
		_items[item] -= requirements[item]
		if _items[item] == 0:
			_items.erase(item)
	if not requirements.is_empty():
		inventory_changed.emit()
	return true

func return_items(items: Dictionary) -> void:
	for item in items:
		if item is ItemData and items[item] > 0:
			_items[item] = _items.get(item, 0) + items[item]
	if not items.is_empty():
		inventory_changed.emit()
