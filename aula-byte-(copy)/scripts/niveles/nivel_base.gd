extends Node2D
class_name NivelBase

@onready var hud: CanvasLayer = $HUD
@onready var punto_inicio: Node2D = get_node_or_null("PuntoInicio")

#---------------------------------------------------------------------------------------------------
# Variables para los límites de la cámara
#---------------------------------------------------------------------------------------------------
@export var camara_alto := -10000000
@export var camara_izquierda := -10000000
@export var camara_derecha := 10000000
@export var camara_abajo := 10000000

#---------------------------------------------------------------------------------------------------
# Tiempo en el nivel
#---------------------------------------------------------------------------------------------------
@export var cuenta_regresiva := 300.0
@export var id_nivel: int = -1
@export var actividad: PackedScene

func _ready() -> void:
	_configurar_z_fondos()
	
	# Para testeo: si corres el nivel directo desde el editor
	if id_nivel >= 0:
		GameManager.nivel_actual = id_nivel

	# Registrar checkpoint por seguridad (si entras directo al nivel)
	if GameManager.has_method("registrar_checkpoint_nivel"):
		GameManager.registrar_checkpoint_nivel()
	
	# Mostrar HUD
	if hud:
		hud.visible = true
	
	# Iniciar la cuenta regresiva propia del nivel
	GameManager.iniciar_tiempo(cuenta_regresiva)
	
	# Cargar el personaje
	_cargar_personaje()
	
func get_actividad() -> PackedScene:
	return actividad
	
func _cargar_personaje() -> void:
	var info_personaje: personajeInfo = GameManager.get_personaje()
	
	if info_personaje and info_personaje.archivo_escena:
		var jugador = info_personaje.archivo_escena.instantiate()
		
		var spawn_pos := Vector2.ZERO
		
		if punto_inicio:
			spawn_pos = punto_inicio.global_position
		else:
			var inicio_por_grupo := get_tree().get_first_node_in_group("PuntoInicio")
			if inicio_por_grupo and inicio_por_grupo is Node2D:
				punto_inicio = inicio_por_grupo
				spawn_pos = punto_inicio.global_position
			else:
				push_warning("NivelBase: no se encontró 'PuntoInicio'. El jugador aparecerá en (0,0).")
				spawn_pos = Vector2.ZERO
		
		jugador.global_position = spawn_pos
		add_child(jugador)
		
		if jugador is CanvasItem:
			jugador.z_index = ZCapas.JUGADOR
			jugador.z_as_relative = false
		
		GameManager.set_jugador(jugador)
		
		if "punto_reaparicion" in jugador:
			jugador.punto_reaparicion = spawn_pos
		
		if jugador.has_method("establecer_limites_camara"):
			jugador.establecer_limites_camara(
				camara_alto,
				camara_izquierda,
				camara_derecha,
				camara_abajo
			)
	else:
		push_warning("No se cargó el personaje: revisa la selección en el menú")
		
func _configurar_z_fondos() -> void:
	_set_z_por_grupo("Z_FONDO_LEJANO", ZCapas.FONDO_LEJANO)
	_set_z_por_grupo("Z_PAREDES", ZCapas.PAREDES)
	_set_z_por_grupo("Z_COLUMNAS", ZCapas.COLUMNAS)
	_set_z_por_grupo("Z_DECOR_FONDO", ZCapas.DECOR_FONDO)
	_set_z_por_grupo("Z_PISOS", ZCapas.PISOS)
	
	_set_z_por_grupo("Z_CHECKPOINT", ZCapas.CHECKPOINT)
	_set_z_por_grupo("Z_CAJAS", ZCapas.CAJAS)
	_set_z_por_grupo("Z_INTERRUPTORES", ZCapas.INTERRUPTORES)
	_set_z_por_grupo("Z_PUERTAS", ZCapas.PUERTAS)
	_set_z_por_grupo("Z_PLATAFORMAS", ZCapas.PLATAFORMAS)
	_set_z_por_grupo("Z_AVISOS", ZCapas.AVISOS)
	
	_set_z_por_grupo("Z_ITEMS", ZCapas.ITEMS)
	_set_z_por_grupo("Z_ENEMIGOS", ZCapas.ENEMIGOS)
	_set_z_por_grupo("Z_FX_SOMBRA", ZCapas.FX_POLVO_SOMBRA)
	_set_z_por_grupo("Z_FX_PARTICULAS", ZCapas.FX_PARTICULAS)
	
func _set_z_por_grupo(nombre_grupo: String, valor_z: int) -> void:
	for nodo in get_tree().get_nodes_in_group(nombre_grupo):
		if nodo is CanvasItem:
			var ci := nodo as CanvasItem
			ci.z_index = valor_z
			ci.z_as_relative = false
