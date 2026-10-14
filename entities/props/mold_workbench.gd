extends Node2D
class_name MoldWorkbench

signal changed
enum MoldMode { UNLOCK_READY, ALWAYS_ASSEMBLE }

## Ready molds become available after their first successful assembly only in mode 0.
@export_enum("Desbloquear molde pronto após montar", "Sempre montar desde o triângulo") var mold_mode: int = MoldMode.ALWAYS_ASSEMBLE
@export var available_shapes: Array[StringName] = [&"triangle", &"square"]
const PRODUCTS = {
	&"triangle": preload("res://data/items/itemTriangulo.tres"),
	&"square": preload("res://data/items/itemQuadrado.tres"),
	&"rectangle": preload("res://data/items/itemRetangulo.tres"),
}
const RECIPES = {
	&"square": preload("res://data/machines/assembly_square.tres"),
	&"rectangle": preload("res://data/machines/assembly_rectangle.tres"),
}
const NAMES = {&"triangle": "Triângulo", &"square": "Quadrado", &"rectangle": "Retângulo"}
const UI_SCRIPT = preload("res://ui/machine_repair/mold_workbench_ui.gd")

var session_active: bool = false
var carried_mold: StringName = &""
var unlocked_molds: Array[StringName] = [&"triangle"]
var steps: Array[StringName] = []
var step_index: int = 0
var target_mold: StringName = &""
var ui: CanvasLayer

func _ready() -> void:
	add_to_group("mold_workbench")
	$Interactable.interaction_started.connect(_on_interaction)
	ui = CanvasLayer.new()
	ui.set_script(UI_SCRIPT)
	ui.workbench = self
	add_child(ui)

func _on_interaction(_body: Node2D) -> void:
	$Interactable.stop_interaction()
	open_workbench()

func open_workbench() -> bool:
	if not session_active or get_tree().get_first_node_in_group("modal_repair_ui") != null:
		return false
	ui.open_ui()
	return true

func reset_session() -> void:
	set_session_active(false)
	unlocked_molds.assign([&"triangle"])
	changed.emit()

func set_session_active(value: bool) -> void:
	session_active = value
	if not value:
		cancel_assembly()
		carried_mold = &""
		if is_instance_valid(ui):
			ui.close_ui()
	changed.emit()

func can_take_ready(shape: StringName) -> bool:
	return shape == &"triangle" or (mold_mode == MoldMode.UNLOCK_READY and unlocked_molds.has(shape))

func begin_mold(shape: StringName) -> bool:
	if not session_active or not available_shapes.has(shape) or not PRODUCTS.has(shape):
		return false
	if carried_mold != &"" or not steps.is_empty():
		return false
	if can_take_ready(shape):
		carried_mold = shape
		ui.close_ui()
		changed.emit()
		return true
	target_mold = shape
	steps = _build_steps(shape)
	step_index = 0
	if steps.is_empty():
		return false
	ui.show_step(RECIPES[steps[0]], step_index + 1, steps.size())
	return true

func _build_steps(shape: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	if can_take_ready(shape):
		return result
	var recipe: AssemblyDefinition = RECIPES.get(shape)
	if recipe == null:
		return result
	# Each intermediate mold must be assembled once per required occurrence.
	for slot in recipe.slots:
		result.append_array(_build_steps(slot.piece.shape_id))
	result.append(shape)
	return result

func complete_step() -> void:
	# Called deferred: cancellation or round expiration wins over pending snaps.
	if not session_active or not ui.visible or steps.is_empty() or not ui.board.is_fully_assembled():
		return
	var completed_shape := steps[step_index]
	if not unlocked_molds.has(completed_shape):
		unlocked_molds.append(completed_shape)
	step_index += 1
	if step_index < steps.size():
		ui.show_step(RECIPES[steps[step_index]], step_index + 1, steps.size())
	else:
		carried_mold = target_mold
		cancel_assembly()
		ui.close_ui()
		GameUI.show_notification("Molde de " + NAMES[carried_mold] + " pronto. Leve à máquina correspondente.")
	changed.emit()

func cancel_assembly() -> void:
	steps.clear()
	step_index = 0
	target_mold = &""

func discard_carried() -> void:
	if not session_active:
		return
	carried_mold = &""
	changed.emit()
	ui.show_choices()

func consume_for(product: ItemData) -> bool:
	if not session_active or carried_mold == &"" or PRODUCTS.get(carried_mold) != product:
		return false
	carried_mold = &""
	changed.emit()
	return true

func _draw() -> void:
	draw_rect(Rect2(-80, -35, 160, 80), Color("392c26"))
	draw_rect(Rect2(-80, -45, 160, 70), Color("986740"))
	draw_rect(Rect2(-64, -32, 128, 47), Color("183c4c"))
	draw_polyline(PackedVector2Array([Vector2(-48, 3), Vector2(-30, -22), Vector2(-12, 3), Vector2(-48, 3)]), Color("89e8ee"), 2)
	draw_rect(Rect2(10, -22, 30, 27), Color("89e8ee"), false, 2)
