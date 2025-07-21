extends Control

@export var imagenes: Array[Texture2D] = []
@export var textos: Array[String] = []
@export var audios: Array[AudioStream] = []

var indice_actual := 0
const esperar_post_audio := 2.0
#-- Variables de efecto para el escritura
var texto_completo := ""
var texto_visible := ""
var indice_letra := 0
var escribiendo := false

@onready var imagen_actual: TextureRect = $imagen_actual
@onready var texto_narrativo: RichTextLabel = $PanelTexto/texto_narrativo
@onready var voz_narrador = $voz_narrador
@onready var btn_siguiente: Button = $btn_siguiente
@onready var temporizador: Timer = $TemSiguiente
@onready var timer_texto: Timer = $TimerTexto

func _ready() -> void:
	# boton siguiente
	btn_siguiente.pressed.connect(_on_boton_siguiente)
	#-- Cuando el audio acaba
	voz_narrador.finished.connect(_on_audio_terminado)
	#-- Cuando el timer vence
	temporizador.timeout.connect(_on_boton_siguiente)
	timer_texto.timeout.connect(_on_timer_texto_timeout)
	
	mostrar_escena_actual()
	
	#--reproducir musica de fondo en bucle
	var musica_intro = preload("res://recursos/audio/Musica/tic-toc-suspenso-7312.wav")
	MusicaGlobal.reproducir(musica_intro, true)

#-------------------------------------------------------------------------------
#--Muestra la imagen, prepara el texto y ejecuta el efecto de escritura
#-------------------------------------------------------------------------------
func mostrar_escena_actual():
	temporizador.stop() #-- Reinicia el Timer
	timer_texto.stop() #-- reinica el Timer
	
	if indice_actual >= imagenes.size():
		ir_a_menu_principal()
		return
	
	#--Mostrar imagen
	imagen_actual.texture = imagenes[indice_actual]
	
	#--texto
	
	texto_completo = textos[indice_actual]
	texto_visible = ""
	indice_letra = 0
	texto_narrativo.text = ""
	escribiendo = true
	timer_texto.start(0.06) #--velocidad de escritura
		
	# reproducir narracion
	if indice_actual < audios.size() and audios[indice_actual]:
		voz_narrador.stream = audios[indice_actual]
		voz_narrador.play()
	else:
		temporizador.start(3.0) #--Cuando acabe el audio esperar 2 segundo
		
#-------------------------------------------------------------------------------
#--Boton siguiente:
#-- - Si aun se esta escribiendo --> muestra todo el texto
#-- - Si ya termino de escribir --> pasa a la siguiente escena
#-------------------------------------------------------------------------------
func _on_boton_siguiente():
	if escribiendo:
		#-- Terminar de escribir instantaneamente
		timer_texto.stop()
		texto_narrativo.text = texto_completo
		escribiendo = false
	else:
		voz_narrador.stop() #--Detiene la narracion anterior
		indice_actual += 1
		mostrar_escena_actual()
	
#-- Al terminar el audio, espera y avanza
func _on_audio_terminado() -> void:
	temporizador.start(esperar_post_audio) # Al acabar el audio
	
#-- Timer para escribir caracter por caracter
func _on_timer_texto_timeout():
	if escribiendo:
		if indice_letra < texto_completo.length():
			texto_visible += texto_completo[indice_letra]
			texto_narrativo.text = texto_visible
			indice_letra += 1
		else:
			timer_texto.stop()
			escribiendo = false
			
#-- Transicion al menu principal
func ir_a_menu_principal():
	MusicaGlobal.detener()
	get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
