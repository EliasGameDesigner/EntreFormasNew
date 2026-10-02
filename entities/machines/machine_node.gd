extends Node2D
class_name MachineNode

enum MachineState { BROKEN, WORKING }

@export var machine_data: MachineData
@export var current_state: MachineState = MachineState.BROKEN
@export var physical_item_scene: PackedScene 
@export var production_time: float = 3.0

@export_group("Configurações de Quebra")
@export var check_breakage_interval: float = 15.0 
@export var breakage_chance: float = 0.25 

@onready var interactable: Interactable = $Interactable
@onready var production_timer: Timer = $ProductionTimer
@onready var breakage_timer: Timer = $BreakageTimer
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var working_audio: AudioStreamPlayer2D = $WorkingAudioPlayer # NOVO: Referência ao som

func _ready() -> void:
	interactable.interaction_started.connect(_on_interaction_started)
	
	production_timer.timeout.connect(_on_production_timer_timeout)
	production_timer.wait_time = production_time
	
	breakage_timer.timeout.connect(_on_breakage_timer_timeout)
	breakage_timer.wait_time = check_breakage_interval
	
	_update_animation()
	
	if current_state == MachineState.WORKING:
		start_production()


func _update_animation() -> void:
	if not animated_sprite:
		return
		
	if current_state == MachineState.WORKING:
		animated_sprite.play("funcionando")
	elif current_state == MachineState.BROKEN:
		animated_sprite.play("quebrada")


func _on_interaction_started(_body: Node2D) -> void:
	interactable.stop_interaction()
	
	if current_state == MachineState.BROKEN:
		return
	elif current_state == MachineState.WORKING:
		GameUI.show_notification("Máquina funcionando normalmente.")


func attempt_repair() -> void:
	if _can_afford_repair():
		_consume_repair_resources()
		repair_machine()
	else:
		GameUI.show_notification("Recursos ou saldo insuficientes para consertar!")


func _can_afford_repair() -> bool:
	if InventoryManager.money < machine_data.repair_cash_cost:
		return false
		
	var required_counts: Dictionary = {}
	for item in machine_data.required_items:
		if required_counts.has(item):
			required_counts[item] += 1
		else:
			required_counts[item] = 1
			
	for item in required_counts:
		if not InventoryManager.has_item(item, required_counts[item]):
			return false
	return true


func _consume_repair_resources() -> void:
	InventoryManager.money -= machine_data.repair_cash_cost
	
	var required_counts: Dictionary = {}
	for item in machine_data.required_items:
		if required_counts.has(item):
			required_counts[item] += 1
		else:
			required_counts[item] = 1
			
	for item in required_counts:
		InventoryManager.remove_item(item, required_counts[item])


func repair_machine() -> void:
	GameUI.show_notification(machine_data.machine_name + " consertada!")
	current_state = MachineState.WORKING
	
	_update_animation() 
	start_production()


func start_production() -> void:
	if machine_data and machine_data.produced_item:
		production_timer.start()
		breakage_timer.start() 
		
		# Toca o som de funcionamento em Loop (se já não estiver tocando)
		if working_audio and not working_audio.playing:
			working_audio.play()


func stop_production() -> void:
	production_timer.stop()
	breakage_timer.stop()
	
	# Para o som de funcionamento
	if working_audio and working_audio.playing:
		working_audio.stop()


func _on_breakage_timer_timeout() -> void:
	if current_state == MachineState.WORKING:
		if randf() <= breakage_chance:
			break_machine()


func break_machine() -> void:
	current_state = MachineState.BROKEN
	
	_update_animation() 
	stop_production()
	
	GameUI.show_notification("ALERTA: A máquina '" + machine_data.machine_name + "' acabou de QUEBRAR!", 4.0)


func _on_production_timer_timeout() -> void:
	if physical_item_scene and machine_data and machine_data.produced_item:
		var instance: PhysicalItem = physical_item_scene.instantiate()
		instance.item_data = machine_data.produced_item
		get_parent().add_child(instance)
		
		var random_offset = Vector2(randf_range(-15, 15), randf_range(-15, 15))
		instance.global_position = spawn_point.global_position + random_offset
