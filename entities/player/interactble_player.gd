extends CharacterBody2D

@export var speed: float = 150.0 

@onready var interaction_label: Label = $InteractionLabel
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer # NOVO: Referência ao áudio de passos

var current_interactable: Interactable = null
var facing := Vector2.DOWN


func _ready() -> void:
	# Per-player material: idle breathing must not affect other instances.
	animated_sprite.material = animated_sprite.material.duplicate()
	if interaction_label:
		interaction_label.text = "[Mouse 1] Interagir"
		interaction_label.hide()


func _unhandled_input(event: InputEvent) -> void:
	if get_tree().get_first_node_in_group("modal_repair_ui") != null:
		return

		
	if current_interactable:
		if event.is_action_pressed("interact") and not event.is_echo():
			current_interactable.start_interaction(self)
			get_viewport().set_input_as_handled()
		elif event.is_action_released("interact"):
			current_interactable.stop_interaction()


func _physics_process(_delta: float) -> void:
	if get_tree().get_first_node_in_group("modal_repair_ui") != null:
		velocity = Vector2.ZERO
		update_animation(Vector2.ZERO)
		return

		
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	move_and_slide()
	update_animation(input_direction)


func update_animation(direction: Vector2) -> void:
	var moving := direction != Vector2.ZERO
	if moving:
		facing = Vector2(signf(direction.x), 0) if abs(direction.x) > abs(direction.y) else Vector2(0, signf(direction.y))
	var mold := get_node_or_null("CarriedMold")
	var carrying: bool = mold != null and mold.visible
	var animation_name := "Carry" if carrying else "Walk"
	if facing.x != 0:
		animation_name += "_Right"
	elif facing.y < 0:
		animation_name += "_Back"
	animated_sprite.flip_h = facing.x < 0
	# Both atlases render at the same world size; side frames have twice the resolution.
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


func _on_interaction_range_area_entered(area: Area2D) -> void:
	if area is Interactable:
		current_interactable = area
		if interaction_label:
			interaction_label.show() 


func _on_interaction_range_area_exited(area: Area2D) -> void:
	if area == current_interactable:
		if current_interactable.is_being_interacted:
			current_interactable.stop_interaction()
		current_interactable = null
		if interaction_label:
			interaction_label.hide()
