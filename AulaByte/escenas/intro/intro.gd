extends Control

@export var imagenes: Array[Texture2D] = []
@export var textos: Array[String] = []
@export var audios: Array[AudioStream] = []

var indice_actual := 0
const esperar_post_audio := 1.0

@onready var imagen_actual: TextureRect = $imagen_actual
@onready var texto_narrativo: RichTextLabel = $PanelTexto/texto_narrativo
@onready var voz_narrador = $voz_narrador
@onready var btn_siguiente: Button = $btn_siguiente
@onready var temporizador: Timer = $TemSiguiente

func _ready() -> void:
	# boton siguiente
	btn_siguiente.pressed.connect(_on_boton_siguiente)
	#-- Cuando el audio acaba
	voz_narrador.finished.connect(_on_audio_terminado)
	#-- Cuando el timer vence
	temporizador.timeout.connect(_on_boton_siguiente)
	
	mostrar_escena_actual()
	
	#--Repetir música de fondo (solo una vez)
	var musica_intro = preload("res://recursos/audio/Musica/tic-toc-suspenso-7312.wav")
	Musica.reproducir(musica_intro, true)
	
func mostrar_escena_actual():
	temporizador.stop() #-- Reinicia el Timer
	
	if indice_actual < imagenes.size():
		imagen_actual.texture = imagenes[indice_actual]
		texto_narrativo.text = textos[indice_actual]
		
	# reproducir narracion
	if indice_actual < audios.size() and audios[indice_actual]:
		voz_narrador.stream = audios[indice_actual]
		voz_narrador.play()
	else:
		temporizador.start(2.0) #--Cuando acabe el audio esperar 2 segundo
	
func _on_boton_siguiente():
	voz_narrador.stop() #--Detiene la narracion anterior
	indice_actual += 1
	mostrar_escena_actual()
	
func _on_audio_terminado() -> void:
	temporizador.start(esperar_post_audio) # Al acabar el audio

func ir_a_menu_principal():
	get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
