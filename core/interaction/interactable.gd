extends Area2D
class_name Interactable

signal interaction_started(body: Node2D)
signal interaction_stopped()
signal interaction_progress(delta: float)

var is_being_interacted: bool = false
var interactor: Node2D = null

# Chame essa função a partir do script do Jogador quando ele apertar o botão de interagir
func start_interaction(body: Node2D) -> void:
	is_being_interacted = true
	interactor = body
	interaction_started.emit(body)

# Chame essa função do Jogador quando ele soltar o botão de interagir
func stop_interaction() -> void:
	if is_being_interacted:
		is_being_interacted = false
		interactor = null
		interaction_stopped.emit()

func _process(delta: float) -> void:
	if is_being_interacted:
		# Se estiver segurando o botão, emite o progresso continuamente
		interaction_progress.emit(delta)
