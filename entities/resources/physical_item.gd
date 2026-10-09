extends Node2D
class_name PhysicalItem

@export var item_data: ItemData
@export var pickup_sound: AudioStream
@export_range(8.0, 160.0) var pickup_radius: float = 64.0
var _collected: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var pickup_area: Area2D = $PickupArea

func _ready() -> void:
	if item_data:
		sprite.texture = item_data.icon
	var circle := CircleShape2D.new()
	circle.radius = pickup_radius
	$PickupArea/CollisionShape2D.shape = circle
	pickup_area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or _collected or item_data == null:
		return
	_collected = true
	InventoryManager.add_item(item_data)
	if pickup_sound:
		AudioManager.play_sfx(pickup_sound)
	queue_free()