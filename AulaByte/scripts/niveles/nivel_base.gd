extends Node2D

class_name NivelBase

@onready var hud: CanvasLayer = $HUD
@onready var punto_control: Area2D = $PuntoControl

#---------------------------------------------------------------------------------------------------
#-- Variables para los limites de la camara
@export var camara_alto := -10000000
@export var camara_izquierda := -10000000
@export var camara_derecha := 10000000
@export var camara_abajo := 10000000
#---------------------------------------------------------------------------------------------------
#-- Tiempo en el nivel
@export var cuenta_regresiva := 120.0

func _ready() -> void:
	#-- estado global del juego
	GameManager.cambiar_estado(GameManager.EstadoJuego.JUGANDO)
	
	#-- reiniciar valores del nivel
	GameManager.reiniciar_nivel()
	
	#-- Mostrar HUD
	hud.visible = true
	
	#-- iniciar cuenta regresiva
	GameManager.iniciar_tiempo(cuenta_regresiva)
	
	#-- cargar el personaje
	_cargar_personaje()
	
func _cargar_personaje() -> void:
	var info_personaje := GameManager.get_personaje()
	
	if info_personaje and info_personaje.archivo_escena:
		var jugador = info_personaje.archivo_escena.instantiate()
		jugador.global_position = punto_control.global_position
		add_child(jugador)
		
		# Registrar en GameManager
		GameManager.set_jugador(jugador)
		
		# Pasar límites de cámara si el jugador lo soporta
		if jugador.has_method("establecer_limites_camara"):
			jugador.establecer_limites_camara(
				camara_alto,
				camara_izquierda,
				camara_derecha,
				camara_abajo
			)
	else:
		push_warning("⚠️ No se cargó el personaje: revisa la selección en el menú")
		
