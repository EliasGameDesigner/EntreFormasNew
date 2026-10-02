extends CanvasLayer
class_name GameUi

@onready var money_label: Label = $Control/MarginContainer/VBoxContainer/MoneyLabel
@onready var items_container: VBoxContainer = $Control/MarginContainer/VBoxContainer/ItemsContainer
@onready var notification_label: Label = $Control/NotificationLabel
@onready var notification_timer: Timer = $Control/NotificationLabel/NotificationTimer

func _ready() -> void:
	# Limpa textos padrões do editor
	notification_label.text = ""
	
	# Conecta aos sinais globais do InventoryManager para atualizar a tela automaticamente
	InventoryManager.money_changed.connect(_on_money_changed)
	InventoryManager.inventory_changed.connect(_on_update_inventory_ui)
	
	# Conecta o timer para apagar a notificação após o tempo acabar
	notification_timer.timeout.connect(_on_notification_timer_timeout)
	
	# Inicializa a UI com os valores atuais
	_on_money_changed(InventoryManager.money)
	_on_update_inventory_ui()

# Atualiza o texto do saldo
func _on_money_changed(new_amount: int) -> void:
	money_label.text = "Saldo da Fábrica: $" + str(new_amount)

# Atualiza a lista de itens na tela dinamicamente
func _on_update_inventory_ui() -> void:
	# Remove os textos antigos antes de desenhar a lista nova
	for child in items_container.get_children():
		child.queue_free()
		
	var all_items = InventoryManager.get_all_items()
	
	# Se o inventário estiver vazio, podemos mostrar um aviso simples
	if all_items.is_empty():
		var empty_label = Label.new()
		empty_label.text = "Inventário Vazio"
		items_container.add_child(empty_label)
		return
		
	# Cria uma linha de texto para cada item diferente que o jogador possui
	for item in all_items:
		var quantity = all_items[item]
		var item_label = Label.new()
		item_label.text = "- " + item.item_name + ": " + str(quantity)
		items_container.add_child(item_label)

# Função pública que qualquer script pode chamar para mandar uma mensagem para a tela
func show_notification(message: String, duration: float = 2.5) -> void:
	notification_label.text = message
	notification_timer.start(duration)

func _on_notification_timer_timeout() -> void:
	notification_label.text = ""
