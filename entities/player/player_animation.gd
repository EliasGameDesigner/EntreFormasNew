extends Node
## Sprite presentation, carried-mold pose and footstep audio.
@onready var animated_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var footstep_player: AudioStreamPlayer = $"../FootstepPlayer"
var facing := Vector2.DOWN

func _ready() -> void:
	animated_sprite.material = animated_sprite.material.duplicate()

func update_animation(direction: Vector2) -> void:
	var moving := direction != Vector2.ZERO
	if moving:
		facing = Vector2(signf(direction.x), 0) if abs(direction.x) > abs(direction.y) else Vector2(0, signf(direction.y))
	var mold := get_parent().get_node_or_null("CarriedMold")
	var carrying: bool = mold != null and mold.visible
	var animation_name := "Carry" if carrying else "Walk"
	if facing.x != 0:
		animation_name += "_Right"
	elif facing.y < 0:
		animation_name += "_Back"
	animated_sprite.flip_h = facing.x < 0
	var sprite_scale := 0.2 if facing.x != 0 else (0.43 if carrying and facing.y < 0 else 0.4)
	if not moving:
		sprite_scale = 0.19
	animated_sprite.scale = Vector2.ONE * sprite_scale
	animated_sprite.position.y = 36.0 - (210.0 if facing.x != 0 or not moving else 100.0) * sprite_scale
	animated_sprite.material.set_shader_parameter("idle_breathing", not moving)
	if not moving:
		animation_name += "_Idle"
	animated_sprite.play(animation_name)
	if mold != null:
		mold.update_pose(facing)
	if moving and not footstep_player.playing:
		footstep_player.play()
	elif not moving and footstep_player.playing:
		footstep_player.stop()
