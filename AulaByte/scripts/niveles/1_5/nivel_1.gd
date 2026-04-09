extends NivelBase
class_name Nivel1

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
	super._ready()
	
	if GameManager.parametros_actividad.has("codigo"):
		codigo_actividad = GameManager.parametros_actividad["codigo"]
	else:
		# 2) Genera su propio código de flechas
		codigo_actividad = _generar_codigo_nivel1(4)
		
		var parametros_actividad = {
			"codigo": codigo_actividad,
			"intentos": 3
		}
		# Solo guarda los parámetros en el GameManager
		GameManager.establecer_parametros_actividad(parametros_actividad)
		
	#-- Mostrar Cuadros
	asignar_imagen()


func _generar_codigo_nivel1(longitud: int = 4) -> Array[int]:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var codigo: Array[int] = []
	for i in range(longitud):
		codigo.append(rng.randi_range(1, 4))
	return codigo


func asignar_imagen() -> void:
	#- Asignar imagen segun el codigo
	if codigo_actividad.size() >= 1:
		asignar_imagen_a_cuadro(cuadro_1, codigo_actividad[0])
	if codigo_actividad.size() >= 2:
		asignar_imagen_a_cuadro(cuadro_2, codigo_actividad[1])
	if codigo_actividad.size() >= 3:
		asignar_imagen_a_cuadro(cuadro_3, codigo_actividad[2])
	if codigo_actividad.size() >= 4:
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
			push_error("Codigo no valido en Nivel_1: %s" % str(codigo))
