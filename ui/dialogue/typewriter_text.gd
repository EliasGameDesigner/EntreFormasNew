extends Node
## Keeps the full text laid out while revealing characters; inherits gameplay pause.
signal finished
signal blip_played
@export var label: Label
@export_range(1.0, 120.0) var characters_per_second: float = 40.0
@export_range(0.02, 0.3) var blip_interval: float = 0.07
@export_range(-40.0, 0.0) var blip_volume_db: float = -18.0
var voice: AudioStreamPlayer
var _message_key := ""
var _active := false
var _typing := false
var _elapsed := 0.0
var _delay := 0.025
var _blip_elapsed := 0.0

func _ready() -> void:
	label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	voice = AudioStreamPlayer.new()
	voice.stream = preload("res://assets/audio/sfx/art_dialogue_blip.wav")
	voice.volume_db = blip_volume_db
	add_child(voice)

func set_message(text: String, key: String) -> void:
	if key == _message_key and label.text == text:
		return
	voice.stop()
	_message_key = key
	label.text = text
	label.visible_characters = 0
	_elapsed = 0.0
	_delay = 1.0 / characters_per_second
	_blip_elapsed = blip_interval
	_typing = not text.is_empty()

func set_active(value: bool) -> void:
	_active = value
	if not value:
		voice.stop()

func is_typing() -> bool:
	return _typing

func finish() -> void:
	voice.stop()
	if not _typing:
		return
	_typing = false
	label.visible_characters = -1
	finished.emit()

func advance(delta: float) -> void:
	if not _active or not _typing or not label.is_visible_in_tree():
		voice.stop()
		return
	_elapsed += delta
	_blip_elapsed += delta
	var revealed := 0
	while _typing and _elapsed >= _delay and revealed < 8:
		_elapsed -= _delay
		var index := label.visible_characters
		var character := label.text.substr(index, 1)
		label.visible_characters += 1
		revealed += 1
		# Whitespace and punctuation stay silent; at most one blip per frame.
		if _blip_elapsed >= blip_interval and (character.to_lower() != character.to_upper() or character.is_valid_int()):
			voice.volume_db = blip_volume_db
			voice.pitch_scale = 1.0 + float(index % 5 - 2) * 0.025
			voice.play()
			_blip_elapsed = 0.0
			blip_played.emit()
		_delay = 1.0 / characters_per_second
		if character in [".", "!", "?", ":"]:
			_delay += 0.14
		elif character in [",", ";"]:
			_delay += 0.07
		if label.visible_characters >= label.text.length():
			finish()

func _process(delta: float) -> void:
	advance(delta)
