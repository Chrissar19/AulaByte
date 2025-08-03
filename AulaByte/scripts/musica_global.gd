extends Node

# =============================================================================
# SISTEMA DE MÚSICA GLOBAL - Controla reproducción de pistas en todo el juego
# =============================================================================

# ============================================================================
# VARIABLES
# ============================================================================
var musica_actual: AudioStreamPlayer
var repetir_actual: bool = false               # Bandera para repetir pista
var pistas_nivel: Array[AudioStream] = []      # Lista de pistas disponibles
var ultimo_indice: int = -1                    # Última pista reproducida

# ============================================================================
# FUNCIÓN PRINCIPAL DE INICIO
# ============================================================================
func _ready() -> void:
	musica_actual = AudioStreamPlayer.new()
	musica_actual.bus = "Musica"
	musica_actual.autoplay = false
	musica_actual.volume_db = -10
	add_child(musica_actual)

	musica_actual.finished.connect(_on_musica_terminada)

	cargar_pistas_nivel()

# ============================================================================
# REPRODUCCIÓN DE MÚSICA
# ============================================================================
func reproducir(stream: AudioStream, repetir: bool = true, volumen_db: float = -10.0) -> void:
	if musica_actual.playing:
		musica_actual.stop()

	musica_actual.stream = stream
	musica_actual.volume_db = volumen_db
	repetir_actual = repetir
	musica_actual.play()
	musica_actual.stream_paused = false

func detener() -> void:
	if musica_actual.playing:
		musica_actual.stop()

# ============================================================================
# GESTIÓN DE PISTAS
# ============================================================================
func cargar_pistas_nivel() -> void:
	pistas_nivel = [
		preload("res://recursos/audio/Musica/01.mp3"),
		preload("res://recursos/audio/Musica/02.mp3"),
		preload("res://recursos/audio/Musica/03.mp3")
	]

func reproducir_aleatorio(volumen_db: float = -10.0) -> void:
	if pistas_nivel.is_empty():
		return

	var indice := randi() % pistas_nivel.size()
	while indice == ultimo_indice and pistas_nivel.size() > 1:
		indice = randi() % pistas_nivel.size()

	ultimo_indice = indice
	reproducir(pistas_nivel[indice], true, volumen_db)

# ============================================================================
# CALLBACK - CUANDO TERMINA LA PISTA
# ============================================================================
func _on_musica_terminada() -> void:
	if repetir_actual:
		musica_actual.play()
