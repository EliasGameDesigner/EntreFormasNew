extends CharacterBody2D

@export var speed: float = 150.0 

@onready var interaction_label: Label = $InteractionLabel
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var footstep_player: AudioStreamPlayer = $FootstepPlayer # NOVO: Referência ao áudio de passos

var current_interactable: Interactable = null


func _ready() -> void:
	if interaction_label:
		interaction_label.text = "[Mouse 1] Interagir"
		interaction_label.hide()


func _process(_delta: float) -> void:
	if get_tree().get_first_node_in_group("modal_repair_ui") != null:
		return

		
	if current_interactable:
		if Input.is_action_just_pressed("interact"):
			current_interactable.start_interaction(self)
		elif Input.is_action_just_released("interact"):
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
	if direction == Vector2.ZERO:
		animated_sprite.play("idle")
		# Se parou de andar, para o som de passos
		if footstep_player.playing:
			footstep_player.stop()
		return

	# Se está andando e o som não está tocando, começa a tocar
	if not footstep_player.playing:
		footstep_player.play()

	if abs(direction.x) > abs(direction.y):
		animated_sprite.play("Walk_Right")
		animated_sprite.flip_h = direction.x < 0
	else:
		if direction.y > 0:
			animated_sprite.play("Walk") 
		else:
			animated_sprite.play("Walk_Back") 


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
