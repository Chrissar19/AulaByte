extends Node
class_name AudioManager

# ============================================================================
# NODOS INTERNOS
# ============================================================================
var musica_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

# ============================================================================
# CONFIG MÚSICA (por estado)
# (pon aquí las rutas reales de tus audios)
# ============================================================================
const MUSICA_MENU: AudioStream            = preload("res://recursos/Audio/musica/menu_principal.mp3")
const MUSICA_SELECCION: AudioStream       = preload("res://recursos/Audio/musica/menu_principal.mp3")
const MUSICA_MINIJUEGO: AudioStream       = preload("res://recursos/Audio/musica/intro.mp3")
const MUSICA_GAME_OVER: AudioStream       = preload("res://recursos/Audio/efectos/Error.wav")
const MUSICA_CREDITOS: AudioStream        = preload("res://recursos/Audio/musica/menu_principal.mp3")

# ============================================================================
# CONFIG SFX (globales / UI)
# ============================================================================
const SFX_CLICK: AudioStream              = preload("res://recursos/Audio/efectos/click.wav")
const SFX_CONFIRMAR: AudioStream          = preload("res://recursos/Audio/efectos/click.wav")
const SFX_ERROR: AudioStream              = preload("res://recursos/Audio/musica/hurt.wav")
const SFX_GANAR: AudioStream              = preload("res://recursos/Audio/efectos/Vida.wav")
const SFX_PERDER_VIDA: AudioStream        = preload("res://recursos/Audio/efectos/Vida.wav")

# ============================================================================
# VARIABLES DE CONTROL
# ============================================================================
var repetir_actual: bool = false
var modo_shuffle: bool = false
var pistas_nivel: Array[AudioStream] = []
var ultimo_indice: int = -1
var _rng := RandomNumberGenerator.new()

var _tween: Tween = null

# ============================================================================
# INICIO
# ============================================================================
func _ready() -> void:
	_rng.randomize()

	# ----- Player de música -----
	musica_player = AudioStreamPlayer.new()
	musica_player.bus = "Musica"
	musica_player.autoplay = false
	musica_player.volume_db = -10.0
	add_child(musica_player)

	# ----- Player de SFX -----
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "Efectos"
	sfx_player.autoplay = false
	sfx_player.volume_db = 0.0
	add_child(sfx_player)

	musica_player.finished.connect(_on_musica_terminada)

	cargar_pistas_nivel()

# ============================================================================
# CARGA DE PISTAS DE NIVEL (shuffle)
# ============================================================================
func cargar_pistas_nivel() -> void:
	pistas_nivel = [
		preload("res://recursos/Audio/musica/time_for_adventure.mp3"),
		preload("res://recursos/Audio/musica/pelea_final.mp3"),
		preload("res://recursos/Audio/musica/neon-pulse-30s-307999.wav")
	]

# ============================================================================
# REPRODUCCIÓN DE MÚSICA
# ============================================================================
func reproducir(stream: AudioStream, repetir: bool = true, volumen_db: float = -10.0, con_fade: bool = true, duracion_fade: float = 0.6) -> void:
	if stream == null:
		return

	modo_shuffle = false
	repetir_actual = repetir

	if not con_fade or not musica_player.playing:
		_cambiar_stream(stream, volumen_db)
		return

	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()

	# Fade out
	_tween.tween_property(musica_player, "volume_db", -40.0, duracion_fade * 0.5)
	_tween.tween_callback(Callable(self, "_cambiar_stream").bind(stream, volumen_db))
	_tween.tween_property(musica_player, "volume_db", volumen_db, duracion_fade * 0.5)

func _cambiar_stream(stream: AudioStream, volumen_db: float) -> void:
	musica_player.stop()
	musica_player.stream = stream
	musica_player.volume_db = volumen_db
	musica_player.stream_paused = false
	musica_player.play()

func detener_musica() -> void:
	modo_shuffle = false
	repetir_actual = false
	if musica_player and musica_player.playing:
		musica_player.stop()

func pausar_musica() -> void:
	if musica_player:
		musica_player.stream_paused = true

func reanudar_musica() -> void:
	if musica_player and musica_player.stream:
		musica_player.stream_paused = false

# ============================================================================
# PLAYLIST ALEATORIA PARA NIVELES
# ============================================================================
func reproducir_aleatorio(volumen_db: float = -10.0) -> void:
	if pistas_nivel.is_empty():
		return

	modo_shuffle = true
	repetir_actual = false

	var indice := _rng.randi_range(0, pistas_nivel.size() - 1)
	if pistas_nivel.size() > 1:
		while indice == ultimo_indice:
			indice = _rng.randi_range(0, pistas_nivel.size() - 1)

	ultimo_indice = indice
	reproducir(pistas_nivel[indice], false, volumen_db)

# ============================================================================
# CALLBACK FIN DE PISTA
# ============================================================================
func _on_musica_terminada() -> void:
	if modo_shuffle:
		reproducir_aleatorio(musica_player.volume_db)
	elif repetir_actual:
		musica_player.play()

# ============================================================================
# SFX
# ============================================================================
func reproducir_sfx(stream: AudioStream, volumen_db: float = 0.0) -> void:
	if stream == null:
		return
	sfx_player.stop()
	sfx_player.stream = stream
	sfx_player.volume_db = volumen_db
	sfx_player.play()

func sfx_ui_click() -> void:
	reproducir_sfx(SFX_CLICK)

func sfx_ui_confirmar() -> void:
	reproducir_sfx(SFX_CONFIRMAR)

func sfx_ui_error() -> void:
	reproducir_sfx(SFX_ERROR)

func sfx_ganar_nivel() -> void:
	reproducir_sfx(SFX_GANAR)

func sfx_perder_vida_evento() -> void:
	reproducir_sfx(SFX_PERDER_VIDA)

# ============================================================================
# INTEGRACIÓN CON GameManager (escucha estado_cambiado)
# ============================================================================
func _on_estado_cambiado(nombre_estado: String) -> void:
	match nombre_estado:
		"MENU_PRINCIPAL":
			reproducir(MUSICA_MENU, true)
		"SELECCION_PERSONAJE":
			reproducir(MUSICA_SELECCION, true)
		"JUGANDO":
			if musica_player.stream and musica_player.stream_paused:
				reanudar_musica()
			else:
				reproducir_aleatorio()
		"MINIJUEGO":
			reproducir(MUSICA_MINIJUEGO, true)
		"PAUSA":
			pausar_musica()
		"GAME_OVER":
			reproducir(MUSICA_GAME_OVER, false)
		"CREDITOS":
			reproducir(MUSICA_CREDITOS, true)
		_:
			pass
