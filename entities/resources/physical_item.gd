extends Node2D
class_name PhysicalItem

@export var item_data: ItemData
@export var pickup_sound: AudioStream # Arraste seu arquivo .wav ou .ogg aqui pelo Inspector

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable: Interactable = $Interactable

func _ready() -> void:
	if item_data and sprite:
		sprite.texture = item_data.icon
		
	interactable.interaction_started.connect(_on_interaction_started)


func _on_interaction_started(_body: Node2D) -> void:
	interactable.stop_interaction()
	
	if item_data:
		InventoryManager.add_item(item_data, 1)
		GameUI.show_notification("Coletou: 1x " + item_data.item_name)
		
		# Toca o som globalmente antes de destruir o objeto
		if pickup_sound:
			AudioManager.play_sfx(pickup_sound)
		
	queue_free()
