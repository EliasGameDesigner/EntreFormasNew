extends Sprite2D
## Cosmetic shuffle bag: every customer appears before a new group is shuffled.
const VARIANTS: Array[Texture2D] = [
	preload("res://data/customers/artisan.tres"),
	preload("res://data/customers/elder.tres"),
	preload("res://data/customers/merchant.tres"),
	preload("res://data/customers/farmer.tres"),
]
@export_range(32.0, 120.0) var display_height: float = 80.0
const WALK_FRAMES: Array[SpriteFrames] = [
	preload("res://data/customers/artisan_walk.tres"),
	preload("res://data/customers/elder_walk.tres"),
	preload("res://data/customers/merchant_walk.tres"),
	preload("res://data/customers/farmer_walk.tres"),
]
@export_range(40.0, 300.0) var walk_speed: float = 140.0
@export_range(4.0, 40.0) var pixels_per_frame: float = 14.0
var walking := false
var walk_frame := 0
var _visual_index := 0
var _walk_distance := 0.0
var _last_position := Vector2.ZERO
var current_variant: int = -1
var _bag: Array[int] = []
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var cutout := ShaderMaterial.new()
	cutout.shader = preload("res://entities/player/sprite_alpha.gdshader")
	material = cutout
	_apply_visual(0)

func next_appearance() -> void:
	if _bag.is_empty():
		for i in range(VARIANTS.size()):
			_bag.append(i)
		# Separate RNG keeps cosmetic variation independent of order quantities.
		for i in range(_bag.size() - 1, 0, -1):
			var j := _rng.randi_range(0, i)
			var swap := _bag[i]
			_bag[i] = _bag[j]
			_bag[j] = swap
		if _bag.size() > 1 and _bag.back() == current_variant:
			var swap := _bag[0]
			_bag[0] = _bag[-1]
			_bag[-1] = swap
	current_variant = _bag.pop_back()
	_apply_visual(current_variant)

func _apply_visual(index: int) -> void:
	walking = false
	set_process(false)
	_visual_index = index
	flip_h = false
	texture = VARIANTS[index]
	scale = Vector2.ONE * display_height / texture.get_height()
	modulate = Color.WHITE

func start_walking(destination: Vector2) -> void:
	walking = true
	flip_h = destination.x < position.x
	_walk_distance = 0.0
	_last_position = position
	walk_frame = 0
	_show_walk_frame()
	set_process(true)

func stop_walking() -> void:
	_apply_visual(_visual_index)

func _process(_delta: float) -> void:
	# Advance by actual travel: a paused tween cannot animate feet in place.
	_walk_distance += position.distance_to(_last_position)
	_last_position = position
	var frames := WALK_FRAMES[_visual_index]
	walk_frame = int(_walk_distance / pixels_per_frame) % frames.get_frame_count(&"walk")
	_show_walk_frame()

func _show_walk_frame() -> void:
	texture = WALK_FRAMES[_visual_index].get_frame_texture(&"walk", walk_frame)
	scale = Vector2.ONE * display_height / texture.get_height()
