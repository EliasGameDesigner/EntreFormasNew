extends RigidBody2D
class_name PhysicalItem

@export var item_data: ItemData
var mold_shape: StringName = &""
@export var pickup_sound: AudioStream
@export_range(8.0, 160.0) var pickup_radius: float = 64.0
var _collected: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var pickup_area: Area2D = $PickupArea

func _ready() -> void:
	add_to_group("ground_carryables")
	var cycle = get_tree().get_first_node_in_group("first_cycle")
	if cycle == null or not cycle.physical_transport:
		freeze = true
		collision_layer = 0
		collision_mask = 0
	if item_data:
		sprite.texture = item_data.icon
		if item_data.icon != null and item_data.world_icon_size > 0.0:
			var dimensions := item_data.icon.get_size()
			sprite.scale = Vector2.ONE * item_data.world_icon_size / maxf(dimensions.x, dimensions.y)
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if mold_shape != &"":
		sprite.texture = load("res://data/items/%s_mold_texture.tres" % mold_shape) if mold_shape in [&"triangle", &"square", &"rectangle", &"parallelogram", &"trapezoid"] else item_data.icon
		sprite.scale = Vector2.ONE * 40.0 / maxf(sprite.texture.get_width(), sprite.texture.get_height())
	var circle := CircleShape2D.new()
	circle.radius = pickup_radius
	$PickupArea/CollisionShape2D.shape = circle
	pickup_area.body_entered.connect(_on_body_entered)

func can_be_picked_by(body: CharacterBody2D) -> bool:
	if _collected or is_queued_for_deletion():
		return false
	# Use the pickup sensor footprint, independently of the small solid body.
	# A direct query also works on the frame the item is dropped/spawned.
	var sensor: CollisionShape2D = $PickupArea/CollisionShape2D
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = sensor.shape
	query.transform = sensor.global_transform
	query.collision_mask = pickup_area.collision_mask
	query.exclude = [get_rid()]
	var in_reach := false
	for hit in get_world_2d().direct_space_state.intersect_shape(query, 32):
		if hit.collider == body:
			in_reach = true
			break
	if not in_reach:
		return false
	var ray := PhysicsRayQueryParameters2D.create(body.global_position, global_position, 1, [body.get_rid(), get_rid()])
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# Outputs can spawn touching another object; prevent explosive separation speeds.
	state.linear_velocity = state.linear_velocity.limit_length(240.0)

func _draw() -> void:
	if item_data == null or item_data.world_icon_size <= 0.0:
		return
	# A small ground shadow separates produced metal parts from the wood floor.
	var radius := item_data.world_icon_size * 0.42
	draw_set_transform(Vector2(0, item_data.world_icon_size * 0.22), 0, Vector2(1, 0.42))
	draw_circle(Vector2.ZERO, radius, Color(0.10, 0.08, 0.06, 0.48))
	draw_set_transform(Vector2.ZERO)

func _on_body_entered(body: Node2D) -> void:
	var cycle = get_tree().get_first_node_in_group("first_cycle")
	if mold_shape != &"" or (cycle != null and cycle.physical_transport):
		return
	if not body.is_in_group("player") or _collected or item_data == null:
		return
	_collected = true
	InventoryManager.add_item(item_data)
	if pickup_sound:
		AudioManager.play_sfx(pickup_sound)
	queue_free()
