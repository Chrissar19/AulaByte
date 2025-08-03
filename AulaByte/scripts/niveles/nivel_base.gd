extends Node2D

@onready var contenedor: Node2D = self
@onready var puntos_inicio: Marker2D = $PuntosInicio/InicioPrincipal
@onready var hud: CanvasLayer = $HUD

@export var camara_alto := -10000000
@export var camara_izquierda := -10000000
@export var camara_derecha := 10000000
@export var camara_abajo := 10000000

@export var cuenta_regresiva := 120.0

func _ready() -> void:
	hud.visible = true
	hud.tiempo_restante = cuenta_regresiva
	
	var id := JugadorSeleccionado.obtener_id()
	var ruta := _obtener_ruta_personaje(id)
	
	if ruta != "":
		var escena_personaje := load(ruta)
		var jugador: Node2D = escena_personaje.instantiate()
		jugador.global_position = puntos_inicio.global_position
		contenedor.add_child(jugador)
		
		if jugador.has_method("establecer_limites_camara"):
			jugador.establecer_limites_camara(
				camara_alto,
				camara_izquierda,
				camara_derecha,
				camara_abajo
			)
	else:
		print("No se cargó el personaje")

func _obtener_ruta_personaje(id: int) -> String:
	match id:
		0: return "res://escenas/personajes/Delgado/Delgado.tscn"
		1: return "res://escenas/personajes/Insuasty/Insuasty.tscn"
		2: return "res://escenas/personajes/Jojoa/Jojoa.tscn"
		3: return "res://escenas/personajes/Romo/Romo.tscn"
		_: return ""
