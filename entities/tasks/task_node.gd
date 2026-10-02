extends Node2D
class_name TaskNode

@export var task_name: String = "Varrer Chão"
@export var required_item: ItemData
@export var required_amount: int = 1
@export var time_to_complete: float = 3.0

@onready var interactable: Interactable = $Interactable
@onready var progress_bar: ProgressBar = $ProgressBar

var current_progress: float = 0.0

func _ready() -> void:
	progress_bar.max_value = time_to_complete
	progress_bar.value = 0.0
	progress_bar.hide()
	
	interactable.interaction_started.connect(_on_interaction_started)
	interactable.interaction_stopped.connect(_on_interaction_stopped)
	interactable.interaction_progress.connect(_on_interaction_progress)

func _on_interaction_started(_body: Node2D) -> void:
	if required_item and not InventoryManager.has_item(required_item, required_amount):
		GameUI.show_notification("Faltam recursos para a tarefa: " + task_name)
		interactable.stop_interaction()
		return
		
	progress_bar.show()

func _on_interaction_stopped() -> void:
	current_progress = 0.0
	progress_bar.value = 0.0
	progress_bar.hide()

func _on_interaction_progress(delta: float) -> void:
	current_progress += delta
	progress_bar.value = current_progress
	
	if current_progress >= time_to_complete:
		complete_task()

func complete_task() -> void:
	interactable.stop_interaction()
	
	if required_item:
		InventoryManager.remove_item(required_item, required_amount)
		
		
	GameUI.show_notification("Tarefa concluída: " + task_name)
	queue_free()
