extends Node
class_name ArtTutorial
## Observes actual play without consuming input, reserving items or pausing time.
signal changed
@export var cycle: FirstCycle
@export var enabled: bool = true
var step: StringName = &""
var dismissed := false
var milestones: Dictionary = {}
var _hands: Node
var _bench: MoldWorkbench

func _ready() -> void:
	_bench = cycle.mold_workbench
	_hands = get_tree().get_first_node_in_group("player_hands")
	cycle.session_prepared.connect(reset)
	cycle.changed.connect(refresh)
	cycle.product_deposited.connect(_on_deposit)
	cycle.order_delivered.connect(_on_delivery)
	_bench.changed.connect(refresh)
	_bench.ui.board.mold_assembled.connect(_on_assembly)
	_hands.changed.connect(refresh)
	for machine in [cycle.triangle_machine, cycle.square_machine]:
		machine.production_started.connect(_on_production_started)
		machine.product_produced.connect(func(_item): refresh())
	refresh()

func reset() -> void:
	milestones.clear()
	dismissed = false
	step = &""
	refresh()
	changed.emit()

func available() -> bool:
	return enabled and cycle.physical_transport and cycle.cycle_number == 1 and not cycle.finished and cycle.workshop_active()

func dismiss() -> void:
	dismissed = true
	changed.emit()

func resume() -> void:
	dismissed = false
	refresh()
	changed.emit()

func _on_deposit(item: ItemData) -> void:
	if available():
		milestones["deposit_" + _shape(item)] = true
	refresh()

func _on_delivery(item: ItemData) -> void:
	if available():
		milestones["delivered_" + _shape(item)] = true
	refresh()

func _on_assembly(shape: StringName) -> void:
	if available() and shape == &"square":
		milestones["assembled_square"] = true
	refresh()

func _on_production_started(item: ItemData) -> void:
	if available():
		milestones["produce_" + _shape(item)] = true
	refresh()

func _shape(item: ItemData) -> String:
	return "triangle" if item == FirstCycle.TRIANGLE else "square"

func _ground_item(shape: StringName, mold: bool) -> bool:
	for item in get_tree().get_nodes_in_group("ground_carryables"):
		if item._collected or item.is_queued_for_deletion():
			continue
		if mold and item.mold_shape == shape:
			return true
		if not mold and item.mold_shape == &"" and item.item_data == MoldWorkbench.PRODUCTS[shape]:
			return true
	return false

func refresh() -> void:
	if not is_instance_valid(_hands):
		return
	var next := _choose_step() if available() else &""
	if next != step:
		step = next
		changed.emit()

func _process(_delta: float) -> void:
	# Also notices dropped objects and opening/closing the workbench.
	if available():
		refresh()

func _choose_step() -> StringName:
	if milestones.has("delivered_triangle") and milestones.has("delivered_square") and milestones.has("assembled_square"):
		return &"complete"
	if _hands.product != null:
		return StringName("deposit_" + _shape(_hands.product))
	if _bench.carried_mold != &"":
		return StringName("insert_" + str(_bench.carried_mold))
	if cycle.preparing and not milestones.has("produce_triangle") and not milestones.has("assembled_square") and not _ground_item(&"triangle", true):
		return &"welcome" if not _bench.ui.visible else &"take_triangle"
	var shape: StringName = &"square" if cycle.order_item == FirstCycle.SQUARE or cycle.delivered > 0 or milestones.has("assembled_square") else &"triangle"
	if cycle.order_item == FirstCycle.TRIANGLE:
		shape = &"triangle"
	var machine: MachineNode = cycle.square_machine if shape == &"square" else cycle.triangle_machine
	if _ground_item(shape, false):
		return StringName("pickup_" + str(shape))
	if machine._mold_cycle_active:
		return StringName("wait_" + str(shape))
	if _ground_item(shape, true):
		return &"recover_mold"
	if shape == &"square":
		return &"take_square" if _bench.can_supply(&"square") else &"assemble_square"
	return &"take_triangle"

func hint() -> Dictionary:
	match step:
		&"welcome":
			return {"title": "Muito prazer. Sou Art!", "text": "Serei seu instrutor nesta fábrica. Ande com WASD e use o botão esquerdo perto de uma estação. Prepare-se à vontade; quando desejar, inicie o ciclo no balcão de atendimento.", "goal": "Inicie o ciclo no balcão de atendimento."}
		&"take_triangle":
			return {"title": "Comecemos pelo triângulo", "text": "O balão do cliente mostra a peça e a quantidade desejadas. Vá à bancada de moldes e clique em Triângulo na lista da esquerda. Esse molde é ilimitado.", "goal": "Pegue um molde triangular na bancada."}
		&"insert_triangle", &"insert_square":
			var shape := "triângulos" if step == &"insert_triangle" else "quadrados"
			return {"title": "Um molde, uma fabricação", "text": "Excelente. Leve o molde à máquina de %s e use o botão esquerdo ao se aproximar. A fabricação consome o molde: precisaremos de outro para a próxima peça." % shape, "goal": "Insira o molde na máquina correspondente."}
		&"wait_triangle", &"wait_square":
			return {"title": "Dê um instante à máquina", "text": "A máquina está trabalhando. Ao terminar, deixará a peça no chão, na saída. O cronômetro do pedido continua correndo; aproveite para planejar o caminho até o balcão.", "goal": "Aguarde a peça sair da máquina."}
		&"pickup_triangle", &"pickup_square":
			return {"title": "A peça está pronta", "text": "Aproxime-se da peça até aparecer a luva e use o botão esquerdo para pegá-la. Só podemos carregar um objeto por vez. O mesmo botão permite largá-lo, longe das estações.", "goal": "Recolha a peça produzida na saída."}
		&"deposit_triangle", &"deposit_square":
			return {"title": "Agora, ao balcão", "text": "Leve a peça ao balcão de atendimento e use o botão esquerdo. Ela ficará empilhada ali. Repita a fabricação até completar a quantidade do balão; a entrega será automática.", "goal": "Deposite a peça no balcão de atendimento."}
		&"assemble_square":
			return {"title": "Dois triângulos, um quadrado", "text": "Na bancada, arraste dois moldes triangulares da lista para o centro. Gire com um duplo clique e una as diagonais. Se desejar, clique na receita de Quadrado para mostrar o guia.", "goal": "Monte o molde quadrado com dois triângulos."}
		&"take_square":
			return {"title": "O novo molde está na lista", "text": "Muito bem! O molde montado fica guardado à esquerda. Clique em Quadrado para carregá-lo, feche a bancada e leve-o à máquina de quadrados. Molde e peça são objetos diferentes.", "goal": "Pegue o molde quadrado na lista da bancada."}
		&"recover_mold":
			return {"title": "Nada se perde por aqui", "text": "Há um molde no chão. Aproxime-se até aparecer a luva e use o botão esquerdo para recuperá-lo. Depois, leve-o à máquina que fabrica a mesma forma.", "goal": "Recupere o molde que foi largado."}
		&"complete":
			return {"title": "Uma bela primeira lição!", "text": "Já domina o essencial: montar moldes, fabricar, carregar e entregar. Observe os próximos pedidos e prepare seu estoque. Estarei torcendo por uma fábrica muito bem organizada.", "goal": "Continue atendendo os clientes. Bom trabalho!"}
	return {"title": "Art", "text": "", "goal": ""}
