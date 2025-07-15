extends Node

var musica_actual: AudioStreamPlayer
var repetir_actual := false #-- Se guarda la pista
var pistas_nivel: Array[AudioStream] = []
var ultimo_indice := -1

func _ready() -> void:
	musica_actual = AudioStreamPlayer.new()
	musica_actual.bus = "Musica"
	musica_actual.autoplay = false
	musica_actual.stream_paused = false
	musica_actual.volume_db = -10
	add_child(musica_actual)
	cargar_pistas_nivel()
	
	#--Conecta la señal finished
	musica_actual.finished.connect(_on_musica_terminada)

func reproducir(stream: AudioStream, repetir := true, volumen_db := -10.0) -> void:
	if musica_actual.playing:
		musica_actual.stop()
	
	musica_actual.stream = stream
	musica_actual.volume_db = volumen_db
	repetir_actual = repetir
	musica_actual.play()
	musica_actual.stream_paused = false
	
func detener():
	if musica_actual.playing:
		musica_actual.stop()
		
func cargar_pistas_nivel():
	pistas_nivel = [
		preload("res://recursos/audio/Musica/01.mp3"),
		preload("res://recursos/audio/Musica/02.mp3"),
		preload("res://recursos/audio/Musica/03.mp3")
	]
func reproducir_aleatorio(volumen_db := -10.0) -> void:
	if pistas_nivel.size() == 0:
		return
		
	var indice := randi() % pistas_nivel.size()
	while indice == ultimo_indice and pistas_nivel.size() > 1:
		indice = randi() % pistas_nivel.size()
		
	ultimo_indice = indice
	reproducir(pistas_nivel[indice], true, volumen_db)
#---------------------------------------------------------------------------------------------------
#call-back interno: Vuelve a reproducir la pista si la señal "repetir" esta activa
#---------------------------------------------------------------------------------------------------
func _on_musica_terminada() -> void:
	if repetir_actual:
		musica_actual.play()
