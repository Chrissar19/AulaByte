extends Node2D
class_name NivelBase

@onready var hud: CanvasLayer = $HUD

@onready var punto_inicio: Node2D = get_node_or_null("PuntoInicio")

#---------------------------------------------------------------------------------------------------
#-- Variables para los limites de la camara
@export var camara_alto := -10000000
@export var camara_izquierda := -10000000
@export var camara_derecha := 10000000
@export var camara_abajo := 10000000
#---------------------------------------------------------------------------------------------------
#-- Tiempo en el nivel
@export var cuenta_regresiva := 120.0

@export var id_nivel: int = -1
@export var actividad: PackedScene

func _ready() -> void:
	#-- ejecuta el nivel, para testeo
	if id_nivel >= 0:
		GameManager.nivel_actual = id_nivel

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
	
func get_actividad() -> PackedScene:
	return actividad
	
func _cargar_personaje() -> void:
	var info_personaje: personajeInfo = GameManager.get_personaje()
	
	if info_personaje and info_personaje.archivo_escena:
		var jugador = info_personaje.archivo_escena.instantiate()
		
		# ------------------------------------------------------------------
		# BUSCAR PUNTO DE INICIO DEL NIVEL
		# ------------------------------------------------------------------
		var spawn_pos := Vector2.ZERO
		
		# 1) Intentar con el nodo "PuntoInicio" directo
		if punto_inicio:
			spawn_pos = punto_inicio.global_position
		else:
			# 2) Como respaldo, intentar por grupo "PuntoInicio"
			var inicio_por_grupo := get_tree().get_first_node_in_group("PuntoInicio")
			if inicio_por_grupo and inicio_por_grupo is Node2D:
				punto_inicio = inicio_por_grupo
				spawn_pos = punto_inicio.global_position
			else:
				# 3) Último recurso: (0, 0)
				push_warning("NivelBase: no se encontró 'PuntoInicio'. El jugador aparecerá en (0,0).")
				spawn_pos = Vector2.ZERO
		
		jugador.global_position = spawn_pos
		add_child(jugador)
		
		# Registrar en GameManager
		GameManager.set_jugador(jugador)
		
		# IMPORTANTE: establecer también su punto de reaparición inicial
		if "punto_reaparicion" in jugador:
			jugador.punto_reaparicion = spawn_pos
		
		# Pasar límites de cámara si el jugador lo soporta
		if jugador.has_method("establecer_limites_camara"):
			jugador.establecer_limites_camara(
				camara_alto,
				camara_izquierda,
				camara_derecha,
				camara_abajo
			)
	else:
		push_warning("No se cargó el personaje: revisa la selección en el menú")
