extends Node2D
class_name MachineNode

signal repaired(machine: MachineNode)
enum MachineState { BROKEN, WORKING }

@export var machine_data: MachineData
@export var current_state: MachineState = MachineState.BROKEN
@export var physical_item_scene: PackedScene
@export_range(0.1, 300.0, 0.1, "or_greater") var production_time: float = 3.0
@export var repair_ui_scene: PackedScene
@export var consume_production_materials: bool = false
## Service mode: one interaction/assembly per output, no passive production.
@export var manual_production: bool = false
@export var manual_available: bool = true
@export var requires_mold: bool = false
@export_range(0.1, 10.0) var manual_cooldown: float = 0.8

@export_group("Configurações de Quebra")
@export var check_breakage_interval: float = 15.0
@export_range(0.0, 1.0) var breakage_chance: float = 0.25

var was_repaired: bool = false
var waiting_for_materials: bool = false
var _repair_ui: MachineRepairUI
var _reserved_materials: Dictionary = {}
var _cycle_active: bool = false
var _reserving: bool = false
var _production_enabled: bool = false
var _mold_cycle_active: bool = false

@onready var interactable: Interactable = $Interactable
@onready var production_timer: Timer = $ProductionTimer
@onready var breakage_timer: Timer = $BreakageTimer
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var working_audio: AudioStreamPlayer2D = $WorkingAudioPlayer
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	add_to_group("machines")
	if machine_data and not machine_data.can_break:
		current_state = MachineState.WORKING
	interactable.interaction_started.connect(_on_interaction_started)
	production_timer.timeout.connect(_on_production_timer_timeout)
	production_timer.one_shot = true
	production_timer.wait_time = production_time
	breakage_timer.timeout.connect(_on_breakage_timer_timeout)
	breakage_timer.wait_time = check_breakage_interval
	InventoryManager.inventory_changed.connect(_on_inventory_changed)
	_update_animation()
	if current_state == MachineState.WORKING:
		start_production()
	_update_status()

func _exit_tree() -> void:
	_production_enabled = false
	_refund_cycle()

func _update_animation() -> void:
	if animated_sprite:
		animated_sprite.play("funcionando" if current_state == MachineState.WORKING else "quebrada")

func _update_status() -> void:
	if not is_instance_valid(status_label) or machine_data == null:
		return
	var state_text := "Produzindo"
	if manual_production:
		state_text = "Mouse1: montar 1 forma" if machine_data.repair_assembly else "Mouse1: produzir 1 triângulo"
		if requires_mold:
			state_text = "Mouse1: inserir molde"
		if not manual_available:
			state_text = "Aguardando atendimento"
		elif not production_timer.is_stopped():
			state_text = "Fabricando: %.1fs" % production_timer.time_left if _mold_cycle_active else "Preparando próxima peça..."
	elif current_state == MachineState.BROKEN:
		state_text = "Quebrada • Mouse1 para reparar"
	elif waiting_for_materials:
		state_text = "Aguardando materiais"
	elif not _cycle_active:
		state_text = "Parada"
	status_label.text = machine_data.machine_name + "\n" + state_text

func _on_interaction_started(_body: Node2D) -> void:
	interactable.stop_interaction()
	if get_tree().get_first_node_in_group("modal_repair_ui") != null:
		return
	if manual_production:
		request_manual_production()
		return
	if current_state == MachineState.BROKEN:
		if not is_instance_valid(_repair_ui) and repair_ui_scene:
			_repair_ui = repair_ui_scene.instantiate()
			add_child(_repair_ui)
			_repair_ui.repair_completed.connect(repair_machine)
		if is_instance_valid(_repair_ui):
			_repair_ui.open_ui(self)
	else:
		GameUI.show_notification("Aguardando materiais no inventário." if waiting_for_materials else "Máquina funcionando normalmente.")

func repair_machine() -> void:
	if current_state != MachineState.BROKEN or machine_data == null:
		return
	current_state = MachineState.WORKING
	was_repaired = true
	_update_animation()
	start_production()
	repaired.emit(self)
	GameUI.show_notification(machine_data.machine_name + " consertada!")

func start_production() -> void:
	if manual_production:
		animated_sprite.pause()
		return
	if current_state != MachineState.WORKING or machine_data == null or machine_data.produced_item == null or physical_item_scene == null:
		return
	_production_enabled = true
	if machine_data.can_break and breakage_timer.is_stopped():
		breakage_timer.start()
	_try_start_cycle()

func _on_inventory_changed() -> void:
	if _production_enabled and not _cycle_active and not _reserving:
		_try_start_cycle.call_deferred()

func _try_start_cycle() -> void:
	if not _production_enabled or current_state != MachineState.WORKING or _cycle_active or _reserving:
		return
	_reserving = true
	if consume_production_materials:
		var recipe := machine_data.production_recipe
		if recipe == null or not recipe.is_valid():
			_wait_for_materials()
			return
		var requirements := recipe.get_requirements()
		if not InventoryManager.take_items(requirements):
			_wait_for_materials()
			return
		_reserved_materials = requirements
	waiting_for_materials = false
	_cycle_active = true
	_reserving = false
	production_timer.start(production_time)
	animated_sprite.play("funcionando")
	if working_audio and not working_audio.playing:
		working_audio.play()
	_update_status()

func _wait_for_materials() -> void:
	waiting_for_materials = true
	_reserving = false
	if working_audio:
		working_audio.stop()
	animated_sprite.pause()
	_update_status()

func _refund_cycle() -> void:
	var refund := _reserved_materials
	_reserved_materials = {}
	_cycle_active = false
	InventoryManager.return_items(refund)

func stop_production() -> void:
	_mold_cycle_active = false
	if manual_production:
		animated_sprite.pause()
	if is_instance_valid(_repair_ui) and manual_production:
		_repair_ui.close_ui()
	_production_enabled = false
	production_timer.stop()
	breakage_timer.stop()
	waiting_for_materials = false
	if working_audio:
		working_audio.stop()
	_refund_cycle()
	_update_status()

func _on_breakage_timer_timeout() -> void:
	if current_state == MachineState.WORKING and randf() <= breakage_chance:
		break_machine()

func break_machine() -> void:
	if manual_production:
		return
	if machine_data == null or not machine_data.can_break or current_state == MachineState.BROKEN:
		return
	current_state = MachineState.BROKEN
	_update_animation()
	stop_production()
	GameUI.show_notification("ALERTA: A máquina '" + machine_data.machine_name + "' acabou de QUEBRAR!", 4.0)

func _on_production_timer_timeout() -> void:
	if manual_production:
		if _mold_cycle_active:
			_mold_cycle_active = false
			production_timer.stop()
			animated_sprite.pause()
			working_audio.stop()
			if manual_available and current_state == MachineState.WORKING:
				_spawn_output()
				GameUI.show_notification("1 " + machine_data.produced_item.item_name + " pronto! Colete na saída da máquina.")
		_update_status()
		return
	if not _cycle_active or not _production_enabled or current_state != MachineState.WORKING:
		return
	# The completed cycle consumes only its own reservation.
	_cycle_active = false
	_reserved_materials.clear()
	_spawn_output()
	_try_start_cycle()

func _spawn_output() -> void:
	var instance: PhysicalItem = physical_item_scene.instantiate()
	instance.item_data = machine_data.produced_item
	var offset := Vector2(randf_range(-15, 15), randf_range(-15, 15))
	# Set the spawn location before enabling the pickup area in the tree.
	var parent_2d := get_parent() as Node2D
	instance.position = parent_2d.to_local(spawn_point.global_position + offset) if parent_2d else spawn_point.global_position + offset
	get_parent().add_child(instance)

func request_manual_production() -> bool:
	if not manual_production or not manual_available or current_state != MachineState.WORKING:
		return false
	if not production_timer.is_stopped() or get_tree().get_first_node_in_group("modal_repair_ui") != null:
		return false
	if machine_data == null or machine_data.produced_item == null or physical_item_scene == null:
		return false
	if requires_mold:
		var workbench := get_tree().get_first_node_in_group("mold_workbench") as MoldWorkbench
		if workbench == null or not workbench.consume_for(machine_data.produced_item):
			GameUI.show_notification("Leve um molde de " + machine_data.produced_item.item_name + " da bancada até esta máquina.")
			return false
		_mold_cycle_active = true
		production_timer.start(production_time)
		animated_sprite.play("funcionando")
		working_audio.play()
		_update_status()
		return true
	if machine_data.repair_assembly == null:
		_spawn_output()
		production_timer.start(manual_cooldown)
		_update_status()
		return true
	if not is_instance_valid(_repair_ui):
		if repair_ui_scene == null:
			return false
		_repair_ui = repair_ui_scene.instantiate()
		add_child(_repair_ui)
		_repair_ui.production_completed.connect(_on_manual_assembly_completed)
	_repair_ui.open_ui(self, true)
	return _repair_ui.visible

func _on_manual_assembly_completed() -> void:
	if manual_production and manual_available and current_state == MachineState.WORKING:
		_spawn_output()
		GameUI.show_notification("1 " + machine_data.produced_item.item_name + " produzido! Colete perto da máquina.")

func set_manual_available(value: bool) -> void:
	manual_available = value
	if not value:
		stop_production()
	_update_status()

func _process(_delta: float) -> void:
	if _mold_cycle_active:
		_update_status()
