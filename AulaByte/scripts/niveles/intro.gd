extends Control

# --- Constantes ---
const ESPERA_POST_AUDIO := 3.0
const VELOCIDAD_ESCRITURA := 0.06

# --- Variables exportadas ---
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
	assert(imagenes.size() == textos.size(), "Las imágenes y los textos no coinciden en tamaño.")

	btn_siguiente.pressed.connect(_al_presionar_siguiente)
	audio_voz.finished.connect(_al_terminar_audio)
	timer_espera.timeout.connect(_al_presionar_siguiente)
	timer_texto.timeout.connect(_al_escribir_texto)

	mostrar_escena()

	var musica_intro := preload("res://recursos/audio/Musica/tic-toc-suspenso-7312.wav")
	MusicaGlobal.reproducir(musica_intro, true)

# --- Mostrar escena actual (imagen, texto y audio) ---
func mostrar_escena() -> void:
	timer_espera.stop()
	timer_texto.stop()

	if indice_escena >= imagenes.size():
		cambiar_a_menu_principal()
		return

	img_escena.texture = imagenes[indice_escena]

	texto_completo = textos[indice_escena]
	texto_visible = ""
	indice_letra = 0
	texto_narrativo.text = ""
	escribiendo = true
	timer_texto.start(VELOCIDAD_ESCRITURA)

	if indice_escena < audios.size() and audios[indice_escena]:
		audio_voz.stream = audios[indice_escena]
		audio_voz.play()
	else:
		timer_espera.start(ESPERA_POST_AUDIO)

# --- Manejo del botón siguiente ---
func _al_presionar_siguiente() -> void:
	if escribiendo:
		timer_texto.stop()
		texto_narrativo.text = texto_completo
		escribiendo = false
	else:
		audio_voz.stop()
		indice_escena += 1
		mostrar_escena()

# --- Al finalizar la narración ---
func _al_terminar_audio() -> void:
	timer_espera.start(ESPERA_POST_AUDIO)

# --- Efecto de escritura progresiva ---
func _al_escribir_texto() -> void:
	if escribiendo:
		if indice_letra < texto_completo.length():
			texto_visible += texto_completo[indice_letra]
			texto_narrativo.text = texto_visible
			indice_letra += 1
		else:
			timer_texto.stop()
			escribiendo = false

# --- Transición al menú principal ---
func cambiar_a_menu_principal() -> void:
	MusicaGlobal.detener()
	get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
