extends Node2D
class_name ResourceSpawnPoint


@export var resource_scene: PackedScene
@export var respawn_time: float = 10.0

var current_resource: Node2D = null
var respawn_timer: Timer

func _ready() -> void:
	respawn_timer = Timer.new()
	respawn_timer.one_shot = true
	respawn_timer.wait_time = respawn_time
	respawn_timer.timeout.connect(_spawn_resource)
	add_child(respawn_timer)
	
	_spawn_resource()

func _spawn_resource() -> void:
	if resource_scene == null:
		push_warning("ResourceSpawnPoint em " + str(global_position) + " está sem uma cena configurada!")
		return
		
	
	var instance = resource_scene.instantiate()
	add_child(instance)
	
	
	instance.position = Vector2.ZERO
	current_resource = instance
	
	
	current_resource.tree_exited.connect(_on_resource_gathered)

func _exit_tree() -> void:
	if current_resource and is_instance_valid(current_resource) and current_resource.tree_exited.is_connected(_on_resource_gathered):
		current_resource.tree_exited.disconnect(_on_resource_gathered)

func _on_resource_gathered() -> void:
	if not is_inside_tree() or get_tree() == null or is_queued_for_deletion():
		return
	if is_instance_valid(respawn_timer) and respawn_timer.is_inside_tree() and not respawn_timer.is_queued_for_deletion():
		respawn_timer.start()
