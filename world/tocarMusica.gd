extends Node2D

# Arraste o seu arquivo de áudio ambiente (já configurado em loop) aqui no Inspector
@export var ambient_sound: AudioStream

func _ready() -> void:
	# Assim que o mapa carregar, manda o AudioManager tocar a música ambiente
	if ambient_sound:
		AudioManager.play_ambient(ambient_sound)
