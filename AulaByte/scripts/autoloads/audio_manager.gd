# ====================================================================
# GESTOR DE AUDIO (AUDIO MANAGER)
# ====================================================================
## Administra los canales de música, efectos y narración de forma global.
extends Node

# ====================================================================
# CONFIGURACIÓN DE RECURSOS (MÚSICA)
# ====================================================================
const MUSICA_MENU: AudioStream      = preload("res://recursos/Audio/musica/MenuPrincipal.wav")
const MUSICA_SELECCION: AudioStream = preload("res://recursos/Audio/musica/seleccion.mp3")
const MUSICA_MINIJUEGO: AudioStream = preload("res://recursos/Audio/musica/actividad.mp3")
const MUSICA_GAME_OVER: AudioStream = preload("res://recursos/Audio/efectos/Error.wav")
const MUSICA_CREDITOS: AudioStream  = preload("res://recursos/Audio/musica/creditos.mp3")

# =============================================================================
#  CONFIGURACIÓN DE RECURSOS (EFECTOS - SFX)
# =============================================================================
const SFX_CLICK: AudioStream        = preload("res://recursos/Audio/efectos/click.wav")
const SFX_CONFIRMAR: AudioStream    = preload("res://recursos/Audio/efectos/click.wav")
const SFX_ERROR: AudioStream        = preload("res://recursos/Audio/efectos/hurt.wav")
const SFX_GANAR: AudioStream        = preload("res://recursos/Audio/efectos/Vida.wav")
const SFX_PERDER_VIDA: AudioStream  = preload("res://recursos/Audio/efectos/Vida.wav")

# =============================================================================
#  VARIABLES DE CONTROL
# =============================================================================
var reproductor_musica: AudioStreamPlayer
var reproductor_sfx: AudioStreamPlayer
var reproductor_narracion: AudioStreamPlayer

var repetir_actual: bool = false
var modo_shuffle: bool = false
var pistas_nivel: Array[AudioStream] = []
var ultimo_indice: int = -1

# Volúmenes base (se pueden modificar desde un menú de opciones)
var volumen_musica_db: float = -10.0
var volumen_sfx_db: float = 0.0
var volumen_narraciones_db: float = -6.0

var _tween: Tween = null
var _rng := RandomNumberGenerator.new()

# =============================================================================
#  INICIO
# =============================================================================
func _ready() -> void:
	_rng.randomize()
	_init_players()

# Crea los players si aún no existen
func _init_players() -> void:
	if reproductor_musica != null:
		return  # retorna si ya están creados

	# ----- Player de música -----
	reproductor_musica = AudioStreamPlayer.new()
	reproductor_musica.bus = "Musica"
	reproductor_musica.autoplay = false
	reproductor_musica.volume_db = volumen_musica_db
	add_child(reproductor_musica)

	# ----- Player de SFX -----
	reproductor_sfx = AudioStreamPlayer.new()
	reproductor_sfx.bus = "Efectos"
	reproductor_sfx.autoplay = false
	reproductor_sfx.volume_db = volumen_sfx_db
	add_child(reproductor_sfx)

	# ----- Player de Narraciones -----
	reproductor_narracion = AudioStreamPlayer.new()
	reproductor_narracion.bus = "Narraciones"
	reproductor_narracion.autoplay = false
	reproductor_narracion.volume_db = volumen_narraciones_db
	add_child(reproductor_narracion)

	# Señal fin de pista de música
	reproductor_musica.finished.connect(_on_musica_terminada)

	# Carga playlist de niveles (solo una vez)
	cargar_pistas_nivel()

# =============================================================================
#  CARGA DE PISTAS PARA NIVELES (SHUFFLE)
# =============================================================================
func cargar_pistas_nivel() -> void:
	if not pistas_nivel.is_empty():
		return
	pistas_nivel = [
		preload("res://recursos/Audio/musica/nivel4.mp3"),
		preload("res://recursos/Audio/musica/nivel1.mp3"),
		preload("res://recursos/Audio/musica/nivel2.mp3"),
		preload("res://recursos/Audio/musica/nivel3.mp3")
	]

# =============================================================================
#  LÓGICA DE MÚSICA
# =============================================================================
## Reproduce una pista con opción de fundido (fade) y repetición.
func reproducir(stream: AudioStream, repetir: bool = true, volumen_db: float = -10.0, con_fade: bool = true, duracion_fade: float = 0.6) -> void:
	if stream == null:
		return
	_init_players()
	modo_shuffle = false
	repetir_actual = repetir
	if not con_fade or not reproductor_musica.playing:
		_cambiar_stream(stream, volumen_db)
		return

	# Si ya hay un tween corriendo, se elimina
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	# Fade out, cambio de pista y fade in
	_tween.tween_property(reproductor_musica, "volume_db", -40.0, duracion_fade * 0.5)
	_tween.tween_callback(Callable(self, "_cambiar_stream").bind(stream, volumen_db))
	_tween.tween_property(reproductor_musica, "volume_db", volumen_db, duracion_fade * 0.5)

func _cambiar_stream(stream: AudioStream, volumen_db: float) -> void:
	_init_players()

	reproductor_musica.stop()
	reproductor_musica.stream = stream
	reproductor_musica.volume_db = volumen_db
	reproductor_musica.stream_paused = false
	reproductor_musica.play()

func detener_musica() -> void:
	_init_players()
	modo_shuffle = false
	repetir_actual = false
	if reproductor_musica and reproductor_musica.playing:
		reproductor_musica.stop()

func pausar_musica() -> void:
	_init_players()
	if reproductor_musica:
		reproductor_musica.stream_paused = true

func reanudar_musica() -> void:
	_init_players()
	if reproductor_musica and reproductor_musica.stream:
		reproductor_musica.stream_paused = false

func reproducir_aleatorio(volumen_db: float = -10.0) -> void:
	_init_players()
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

# =============================================================================
#  MANEJO DE SEÑALES Y EVENTOSA
# =============================================================================
func _on_musica_terminada() -> void:
	_init_players()
	if modo_shuffle:
		reproducir_aleatorio(reproductor_musica.volume_db)
	elif repetir_actual:
		reproductor_musica.play()
		
## Callback vinculado al GameManager para reaccionar a cambios de escena/estado.
func _on_estado_cambiado(nombre_estado: String) -> void:
	# Por si llega una señal muy temprano
	_init_players()

	match nombre_estado:
		"MENU_PRINCIPAL":
			reproducir(MUSICA_MENU, true, volumen_musica_db)
		"SELECCION_PERSONAJE":
			reproducir(MUSICA_SELECCION, true, volumen_musica_db)
		"JUGANDO":
			# Si esta reanudando desde pausa, sigue
			if reproductor_musica.stream and reproductor_musica.stream_paused:
				reanudar_musica()
			else:
				reproducir_aleatorio(volumen_musica_db)
		"MINIJUEGO":
			reproducir(MUSICA_MINIJUEGO, true, volumen_musica_db)
		"PAUSA":
			pausar_musica()
		"GAME_OVER":
			reproducir(MUSICA_GAME_OVER, false, volumen_musica_db)
		"CREDITOS":
			reproducir(MUSICA_CREDITOS, true, volumen_musica_db)
		_:
			pass

# =============================================================================
#  SFX
# =============================================================================
func reproducir_sfx(stream: AudioStream, volumen_db: float = 0.0) -> void:
	if stream == null:
		return
	_init_players()
	reproductor_sfx.stop() # Para UI está bien cortar el anterior
	reproductor_sfx.stream = stream
	reproductor_sfx.volume_db = volumen_db
	reproductor_sfx.play()

func sfx_ui_click() -> void:
	reproducir_sfx(SFX_CLICK, volumen_sfx_db)

func sfx_ui_confirmar() -> void:
	reproducir_sfx(SFX_CONFIRMAR, volumen_sfx_db)

func sfx_ui_error() -> void:
	reproducir_sfx(SFX_ERROR, volumen_sfx_db)

func sfx_ganar_nivel() -> void:
	reproducir_sfx(SFX_GANAR, volumen_sfx_db)

func sfx_perder_vida_evento() -> void:
	reproducir_sfx(SFX_PERDER_VIDA, volumen_sfx_db)

# =============================================================================
#  NARRACIONES
# =============================================================================
func reproducir_narracion(stream: AudioStream, volumen_db: float = -6.0) -> void:
	if stream == null:
		return
	_init_players()
	reproductor_narracion.stop()
	reproductor_narracion.stream = stream
	reproductor_narracion.volume_db = volumen_db
	reproductor_narracion.play()

func detener_narracion() -> void:
	_init_players()
	if reproductor_narracion and reproductor_narracion.playing:
		reproductor_narracion.stop()

# =============================================================================
#  VOLUMEN (para menú de opciones)
# =============================================================================
func set_volumen_musica_db(db: float) -> void:
	volumen_musica_db = db
	_init_players()
	if reproductor_musica:
		reproductor_musica.volume_db = db

func set_volumen_sfx_db(db: float) -> void:
	volumen_sfx_db = db
	_init_players()
	if reproductor_sfx:
		reproductor_sfx.volume_db = db

func set_volumen_narraciones_db(db: float) -> void:
	volumen_narraciones_db = db
	_init_players()
	if reproductor_narracion:
		reproductor_narracion.volume_db = db
