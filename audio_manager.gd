extends Node

# Player dedicado para o som ambiente/música, para não se misturar com os efeitos sonoros rápidos
var ambient_player: AudioStreamPlayer

func _ready() -> void:
	# Criamos o player de ambiente assim que o jogo abre
	ambient_player = AudioStreamPlayer.new()
	ambient_player.bus = "Master" # Aqui você pode rotear para um bus de "Music" depois, se quiser
	add_child(ambient_player)


# Toca um efeito sonoro instantâneo e se auto-destrói quando terminar (Itens, cliques)
func play_sfx(stream: AudioStream) -> void:
	if not stream:
		return
		
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	add_child(sfx_player)
	sfx_player.play()
	
	sfx_player.finished.connect(sfx_player.queue_free)


# NOVA FUNÇÃO: Toca o som ambiente global
func play_ambient(stream: AudioStream) -> void:
	if not stream:
		return
		
	# Se já estiver tocando esse mesmo som, não faz nada
	if ambient_player.stream == stream and ambient_player.playing:
		return
		
	ambient_player.stream = stream
	ambient_player.play()


# NOVA FUNÇÃO: Para o som ambiente
func stop_ambient() -> void:
	if ambient_player.playing:
		ambient_player.stop()
