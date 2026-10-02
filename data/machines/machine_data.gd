extends Resource
class_name MachineData

@export var machine_name: String = "Nova Máquina"
@export var cost: int = 100 # Custo em dinheiro para comprar/construir
@export var repair_cash_cost: int = 50 
@export var produced_item: ItemData

@export_group("Requisitos de Conserto")
@export var required_items: Array[ItemData] 
@export var repair_image: Texture2D 
