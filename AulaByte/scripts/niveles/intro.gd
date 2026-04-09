extends Control
class_name Intro

# ============================================================================
# CONSTANTES
# ============================================================================
const ESPERA_POST_AUDIO := 0.5          # Tiempo de espera tras el audio (si quieres auto-avance)
const VELOCIDAD_ESCRITURA := 0.06       # Velocidad del efecto máquina de escribir

# ============================================================================
# --- Variables exportadas ---
# ============================================================================
@export var imagenes: Array[Texture2D] = []
@export var textos: Array[String] = []
@export var audios: Array[AudioStream] = []

# --- Referencias a nodos ---
@onready var img_escena: TextureRect = $imagen_actual
@onready var texto_narrativo: RichTextLabel = $PanelTexto/texto_narrativo
@onready var audio_voz: AudioStreamPlayer = $voz_narrador
@onready var btn_siguiente: Button = $btn_siguiente
@onready var timer_espera: Timer = $TemSiguiente
@onready var timer_texto: Timer = $TimerTexto

# --- Variables internas ---
var indice_escena := 0
var texto_completo := ""
var texto_visible := ""
var indice_letra := 0
var escribiendo := false

# --- Funciones principales ---
func _ready() -> void:
	# Arrays básicos
	assert(imagenes.size() == textos.size(), "Las imágenes y los textos no coinciden en tamaño.")
	if not audios.is_empty():
		assert(audios.size() == textos.size(), "Si usas audios, debe haber uno por texto (mismo tamaño).")

	# Asegurar autowrap por si acaso, aunque los textos sean cortos
	texto_narrativo.autowrap_mode = TextServer.AUTOWRAP_WORD

	btn_siguiente.pressed.connect(_al_presionar_siguiente)
	audio_voz.finished.connect(_al_terminar_audio)
	timer_espera.timeout.connect(_al_presionar_siguiente)
	timer_texto.timeout.connect(_al_escribir_texto)

	mostrar_escena()
	AudioManager.detener_musica()
	var musica_intro := preload("res://recursos/Audio/musica/intro.mp3")
	AudioManager.reproducir(musica_intro, true)

# --- Mostrar escena actual (imagen, texto y audio) ---
func mostrar_escena() -> void:
	timer_espera.stop()
	timer_texto.stop()

	if indice_escena >= imagenes.size():
		cambiar_a_menu_principal()
		return

	# Imagen de la escena actual
	img_escena.texture = imagenes[indice_escena]

	# Reset del texto
	texto_completo = textos[indice_escena]
	texto_visible = ""
	indice_letra = 0
	texto_narrativo.text = ""
	escribiendo = true

	# Iniciar efecto máquina de escribir
	timer_texto.start(VELOCIDAD_ESCRITURA)

	# Reproducir audio de la escena (si existe)
	if not audios.is_empty() and audios[indice_escena]:
		audio_voz.stream = audios[indice_escena]
		audio_voz.play()
	else:
		timer_espera.start(ESPERA_POST_AUDIO)

# --- Manejo del botón siguiente ---
func _al_presionar_siguiente() -> void:
	if escribiendo:
		# Terminar de escribir todo de golpe
		timer_texto.stop()
		texto_visible = texto_completo
		texto_narrativo.text = texto_visible
		escribiendo = false
	else:
		# Pasar a la siguiente escena
		audio_voz.stop()
		indice_escena += 1
		mostrar_escena()

func _al_terminar_audio() -> void:
	timer_espera.start(ESPERA_POST_AUDIO)

# --- Efecto de escritura progresiva ---
func _al_escribir_texto() -> void:
	if not escribiendo:
		return

	if indice_letra < texto_completo.length():
		texto_visible += texto_completo[indice_letra]
		indice_letra += 1
		texto_narrativo.text = texto_visible
	else:
		timer_texto.stop()
		escribiendo = false

# --- Transición al menú principal ---
func cambiar_a_menu_principal() -> void:
	AudioManager.detener_narracion()
	AudioManager.detener_musica()
	GameManager.ir_a_menu_principal()

# --- Conexión vieja del TimerTexto ---
func _on_timer_texto_timeout() -> void:
	_al_escribir_texto()

# --- Saltar intro completa con ESC ---
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		cambiar_a_menu_principal()
