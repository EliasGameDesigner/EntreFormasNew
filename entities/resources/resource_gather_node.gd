extends Node2D
class_name ResourceGatherNode

@export var item_to_give: ItemData
@export var amount_to_give: int = 1
@export var time_to_gather: float = 2.0

@onready var interactable: Interactable = $Interactable
@onready var progress_bar: ProgressBar = $ProgressBar

var current_progress: float = 0.0

func _ready() -> void:
	progress_bar.max_value = time_to_gather
	progress_bar.value = 0.0
	progress_bar.hide()
	
	interactable.interaction_started.connect(_on_interaction_started)
	interactable.interaction_stopped.connect(_on_interaction_stopped)
	interactable.interaction_progress.connect(_on_interaction_progress)

func _on_interaction_started(_body: Node2D) -> void:
	progress_bar.show()

func _on_interaction_stopped() -> void:
	current_progress = 0.0
	progress_bar.value = 0.0
	progress_bar.hide()

func _on_interaction_progress(delta: float) -> void:
	current_progress += delta
	progress_bar.value = current_progress
	
	if current_progress >= time_to_gather:
		finish_gathering()

func finish_gathering() -> void:
	interactable.stop_interaction()
	
	if item_to_give:
		InventoryManager.add_item(item_to_give, amount_to_give)
		GameUI.show_notification("Coletou: " + str(amount_to_give) + "x " + item_to_give.item_name)
	
	queue_free()
