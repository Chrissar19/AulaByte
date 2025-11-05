extends NivelBase


@onready var cuadro_1: TextureRect = $Cuadros/Cuadro1
@onready var cuadro_2: TextureRect = $Cuadros/Cuadro2
@onready var cuadro_3: TextureRect = $Cuadros/Cuadro3

var fle_arriba: Texture2D = preload("res://recursos/imagenes/objetos/Flecha arriba.png")
var fle_izquierda: Texture2D = preload("res://recursos/imagenes/objetos/Flecha izq.png")
var fle_abajo: Texture2D = preload("res://recursos/imagenes/objetos/Flecha abajo.png")
var fle_derecha: Texture2D = preload("res://recursos/imagenes/objetos/Flecha dere.png")

var codigo_actividad: Array[int] = []
#---------------------------------------------------------------------------------------------------

func _ready() -> void:
	#-- Llama a _ready de la nivel_base
	super._ready()
	
	#-- Solo generar codigo si no exiete en Gamemanager
	if not GameManager.parametros_actividad.has("codigo"):
		codigo_actividad = GameManager.generar_codigo()
		
		var parametros_actividad = {
			"codigo": codigo_actividad,
			"intentos": 3
		}
		GameManager.establecer_parametros_actividad(parametros_actividad)
		
	else:
		codigo_actividad = GameManager.parametros_actividad["codigo"]
		
	#-- Mostrar Cuadros
	asignar_imagen()
	
		
func asignar_imagen() -> void:
	#- Asignar imagen segun el codigo
	asignar_imagen_a_cuadro(cuadro_1, codigo_actividad[0])
	asignar_imagen_a_cuadro(cuadro_2, codigo_actividad[1])
	asignar_imagen_a_cuadro(cuadro_3, codigo_actividad[2])

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
