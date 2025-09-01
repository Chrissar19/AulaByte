extends NivelBase


@onready var cuadro_1: TextureRect = $Cuadros/Cuadro1
@onready var cuadro_2: TextureRect = $Cuadros/Cuadro2
@onready var cuadro_3: TextureRect = $Cuadros/Cuadro3
@onready var cuadro_4: TextureRect = $Cuadros/Cuadro4

var fle_arriba: Texture2D = preload("res://recursos/imagenes/objetos/Flecha arriba.png")
var fle_izquierda: Texture2D = preload("res://recursos/imagenes/objetos/Flecha izq.png")
var fle_abajo: Texture2D = preload("res://recursos/imagenes/objetos/Flecha abajo.png")
var fle_derecha: Texture2D = preload("res://recursos/imagenes/objetos/Flecha dere.png")

var codigo_actividad: Array[int] = []


#---------------------------------------------------------------------------------------------------

func _ready() -> void:
	#-- Llama a _ready de la nivel_base
	super._ready()
	
	#-- generar codigo aleatorio
	generar_codigo_nivel()
	asignar_imagen()
	
	#-- Establecer parametros
	var parametros_actividad = {
		"codigo": codigo_actividad,
		"intentos": 3
	}
	
func generar_codigo_nivel() -> void:
	var numero_aleatorio = RandomNumberGenerator.new()
	numero_aleatorio.randomize()
	
	codigo_actividad = []
	for i in range(4):
		codigo_actividad.append(numero_aleatorio.randi_range(1, 4))
		
func asignar_imagen() -> void:
	#- Asignar imagen segun el codigo
	asignar_imagen_a_cuadro(cuadro_1, codigo_actividad[0])
	asignar_imagen_a_cuadro(cuadro_2, codigo_actividad[1])
	asignar_imagen_a_cuadro(cuadro_3, codigo_actividad[2])
	asignar_imagen_a_cuadro(cuadro_4, codigo_actividad[3])

func asignar_imagen_a_cuadro(cuadro: TextureRect, codigo: int) -> void:
	match codigo:
		1:
			cuadro.texture = fle_arriba
		2:
			cuadro.texture = fle_izquierda
		3:
			cuadro.texture = fle_abajo
		4:
			cuadro.texture = fle_derecha
		_:
			push_error("Codigo no valido en Nivel_1" % codigo)
