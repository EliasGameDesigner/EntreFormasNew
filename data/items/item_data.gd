extends Resource
class_name ItemData

@export var item_name: String = "Novo Item"
@export var icon: Texture2D
## Optional maximum sprite dimension in world pixels; zero preserves native size.
@export_range(0.0, 160.0) var world_icon_size: float = 0.0
@export var price: int = 10 # Preço de venda em dinheiro
