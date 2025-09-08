extends Node

# ============================================================================
# Señales globales
# ============================================================================
signal vida_actualizada(nueva_vida: int)
signal jugador_muerto
signal nivel_completado
signal personaje_seleccionado(id: int)
signal tiempo_actualizado(segundos: int)
signal tiempo_terminado
signal jugador_gana_puntos(puntos: int)
signal estado_cambiado(nuevo_estado: String)
signal actividad_superada
signal actividad_fallida

# ============================================================================
# Enumeraciones y constantes
# ============================================================================
enum EstadoJuego {
	MENU_PRINCIPAL,
	SELECCION_PERSONAJE,
	CARGANDO,
	JUGANDO,
	PAUSA,
	MINIJUEGO,
	TRANSICION_NIVEL,
	GAME_OVER,
	CREDITOS
}

const VIDAS_INICIALES: int = 3
const VIDAS_MAX: int = 5
const TIEMPO_POR_NIVEL: float = 90.0

# ============================================================================
# Variables globales
# ============================================================================
var estado_actual: EstadoJuego = EstadoJuego.MENU_PRINCIPAL
var estado_anterior: EstadoJuego

# Personaje
var id_personaje: int = -1
var info_personaje: personajeInfo = null
var jugador_ref: Node = null

# Vidas y puntos
var vidas: int = 3
var puntos: int = 0

# Tiempo
var tiempo_nivel_actual := 0.0
var tiempo_restante := 90.0
var tiempo_activo := false

#-- Actividades
var actividades_por_nivel := {
	0: preload("res://escenas/Niveles/actividades/actividad_cero.tscn"),
	1: preload("res://escenas/Niveles/actividades/actividad_primer_nivel.tscn"),
}

var parametros_actividad: Dictionary = {}
var codigo_actividad_actual: Array[int] = []
var codigo_generado: bool = false
var puerta_actual: Node = null
var ui_actividad: CanvasLayer

#-- Niveles
@export var niveles: Niveles = preload("res://datos/niveles.tres")
var nivel_actual: int = 0
var nivel_precargado: PackedScene

#--------------------------------------------------------------------------------
# PROCESS
#--------------------------------------------------------------------------------
func _process(delta: float) -> void:
	#-- El tiempo contara solo si es juego esta corriendo
	if estado_actual == EstadoJuego.JUGANDO:
		_actualizar_tiempo(delta)
		
func _actualizar_tiempo(delta: float) -> void:
	tiempo_nivel_actual += delta
	if tiempo_restante > 0:
		tiempo_restante -= delta
		tiempo_restante = max(tiempo_restante, 0)
		emit_signal("tiempo_actualizado", int(tiempo_restante))
		
		if tiempo_restante == 0 and tiempo_activo:
			tiempo_activo = false
			emit_signal("tiempo_terminado")
			cambiar_estado(EstadoJuego.GAME_OVER)
				
#--------------------------------------------------------------------------------
# MAQUINA DE ESTADOS DE NIVELES
#--------------------------------------------------------------------------------
func cambiar_estado(nuevo_estado: EstadoJuego) -> void:
	#-- Salir del estado actual
	if nuevo_estado == estado_actual:
		return
	_salir_estado(estado_actual)
	estado_anterior = estado_actual
	estado_actual = nuevo_estado
	
	#-- Entrar al nuevo estado
	_entrar_estado(estado_actual)
	emit_signal("estado_cambiado", EstadoJuego.keys()[estado_actual])
	
func _entrar_estado(estado: EstadoJuego) -> void:
	match estado:
		EstadoJuego.JUGANDO:
			print("Entrando a estado JUGANDO")
			get_tree().paused = false
			tiempo_activo = true
			
		EstadoJuego.PAUSA:
			print("Entrando a estado PAUSA")
			get_tree().paused = true
			
		EstadoJuego.MINIJUEGO:
			print("Entrando a estado MINIJUEGO")
			get_tree().paused = true
			_mostrar_minijuego()
			
		EstadoJuego.CARGANDO:
			print("Entrando a estado CARGANDO")
			precargar_nivel()
			pantalla_de_carga()
			
		EstadoJuego.TRANSICION_NIVEL:
			print("Entrando a estado TRANSICION_NIVEL")
			transicion_siguiente_nivel()
			
		EstadoJuego.GAME_OVER:
			print("Entrando a estado GAME_OVER")
			get_tree().change_scene_to_file("res://escenas/menu/menu_perder.tscn")
			
func _salir_estado(estado: EstadoJuego) -> void:
	match estado:
		EstadoJuego.MINIJUEGO:
			print("Saliendo de estado MINIJUEGO")
			_limpiar_minijuego()
	

#--------------------------------------------------------------------------------
# CONEXION CON EL JUGADOR
#--------------------------------------------------------------------------------
func set_jugador(jugador: Node) -> void:
	jugador_ref = jugador
	
	if jugador_ref.has_signal("jugador_gana_vida"):
		jugador_ref.jugador_gana_vida.connect(_on_jugador_gana_vida)
		
	if jugador_ref.has_signal("jugador_pierde_vida"):
		jugador_ref.jugador_pierde_vida.connect(_on_jugador_pierde_vida)
	else:
		print("El jugador no tiene señal jugador_pierde_vida")
		
#--------------------------------------------------------------------------------
# CALLBACKS DE SEÑALES DEL JUGADOR
#--------------------------------------------------------------------------------
func _on_jugador_gana_vida(vidas_actuales: int) -> void:
	vidas = vidas_actuales
	emit_signal("jugador_gana_vida", vidas)
	
func _on_jugador_pierde_vida(dmg: int) -> void:
	perder_vida()

#--------------------------------------------------------------------------------
# Selección de personaje
#--------------------------------------------------------------------------------
func seleccionar_personaje(id: int, info: personajeInfo = null) -> void:
	id_personaje = id
	info_personaje = info
	emit_signal("personaje_seleccionado", id)

func get_personaje() -> personajeInfo:
	return info_personaje

#--------------------------------------------------------------------------------
# Manejo de puntos
#--------------------------------------------------------------------------------
func agregar_puntos(cantidad: int) -> void:
	if cantidad > 0:
		puntos += cantidad
		emit_signal("jugador_gana_puntos", puntos)

func reiniciar_puntos() -> void:
	puntos = 0
	emit_signal("jugador_gana_puntos", puntos)

func get_puntos() -> int:
	return puntos

#--------------------------------------------------------------------------------
# Manejo de vidas
#--------------------------------------------------------------------------------
func perder_vida() -> void:
	if vidas > 0:
		vidas -= 1
		emit_signal("vida_actualizada", vidas)
		print("vida perdida, VIDAS: ", vidas)
		
		if vidas <= 0:
			vidas = 0
			print("HAS MUERTO (GameManager)")
			emit_signal("jugador_muerto")
			cambiar_estado(EstadoJuego.GAME_OVER)
	

func ganar_vida() -> void:
	if vidas < VIDAS_MAX:
		vidas += 1
		emit_signal("vida_actualizada", vidas)
	print("ganas vida, VIDAS: ", vidas)

func reiniciar_vidas() -> void:
	vidas = 3
	emit_signal("vida_actualizada", vidas)

func get_vidas() -> int:
	return vidas
	
#--------------------------------------------------------------------------------
# Manejo de tiempo
#--------------------------------------------------------------------------------
func get_tiempo() -> float:
	return tiempo_nivel_actual
	
func iniciar_tiempo(segundos: float = TIEMPO_POR_NIVEL) -> void:
	tiempo_restante = segundos
	tiempo_activo = true
	emit_signal("tiempo_actualizado", int(tiempo_restante))
	
# ============================================================================
# Manejo de niveles
# ============================================================================
func get_nivel_actual() -> PackedScene:
	if niveles and nivel_actual < niveles.nivel.size():
		return niveles.nivel[nivel_actual]
	return null
	
func precargar_nivel() -> void:
	var siguiente_indice = nivel_actual + 1
	if niveles and siguiente_indice < niveles.nivel.size():
		nivel_precargado = niveles.nivel[siguiente_indice]
		#-- Precargar recursos del nivel
		if nivel_precargado:
			ResourceLoader.load_threaded_request(nivel_precargado.resource_path)
	
func cargar_nivel_actual() -> void:
	tiempo_nivel_actual = 0.0
	iniciar_tiempo(TIEMPO_POR_NIVEL)
	var nivel: PackedScene = get_nivel_actual()
	if nivel:
		get_tree().change_scene_to_packed(nivel)
	else:
		cambiar_estado(EstadoJuego.CREDITOS)
		
func transicion_siguiente_nivel() -> void:
	if not niveles or nivel_actual + 1 >= niveles.nivel.size():
		#-- Ir a creditos
		cambiar_estado(EstadoJuego.CREDITOS)
	else:
		nivel_actual += 1
		cambiar_estado(EstadoJuego.CARGANDO)
	
func siguiente_nivel() -> void:
	cambiar_estado(EstadoJuego.TRANSICION_NIVEL)

func completar_nivel() -> void:
	emit_signal("nivel_completado")
	
func pantalla_de_carga() -> void:
	get_tree().change_scene_to_file("res://escenas/ui/pantalla_carga.tscn")

func reiniciar_nivel() -> void:
	reiniciar_puntos()
	reiniciar_vidas()
	tiempo_nivel_actual = 0.0
	codigo_generado = false
	codigo_actividad_actual.clear()
	cambiar_estado(EstadoJuego.JUGANDO)

# =====================================================================
# ACTIVIDAD POR NIVEL
# =====================================================================
func solicitar_minijuego() -> void:
	print("Solicitando actividad para nivel: ", nivel_actual)
	cambiar_estado(EstadoJuego.MINIJUEGO)
	
func _mostrar_minijuego() -> void:
	var nivel := nivel_actual
	
	if actividades_por_nivel.has(nivel):
		var escena_actividad = actividades_por_nivel[nivel]
		if escena_actividad:
			#-- Crea un CanvasLayer para la actividad
			ui_actividad = CanvasLayer.new()
			ui_actividad.layer = 15 #-- Capa para que la actividad este encima
			get_tree().root.add_child(ui_actividad)
			
			var actividad = escena_actividad.instantiate()
			
			#-- Pasar los parametros de cada actividad si esta definido
			if not parametros_actividad.is_empty() and actividad.has_method("configurar_con_parametros"):
				actividad.configurar_con_parametros(parametros_actividad)
			
			#-- Ajustar pantalla si es UI
			if actividad is Control:
				actividad.set_anchors_preset(Control.PRESET_FULL_RECT)
				actividad.mouse_filter = Control.MOUSE_FILTER_STOP
				actividad.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
				ui_actividad.add_child(actividad)
			elif actividad is Node2D:
				actividad.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
				#-- Añadir la actividad a Canvas
				ui_actividad.add_child(actividad)
				
				#-- Obtenemos la camara actual
				var pantalla = get_tree().root.get_viewport()
				var camara = pantalla.get_camera_2d()
				
				if camara:
					#-- posicionamos la actividad en el entro de la camara
					actividad.global_position = camara
				else:
					var tam_pantalla = pantalla.get_visible_rect().size
					actividad.global_position = tam_pantalla / 2
				
			#-- Conectar señal
			if actividad.has_signal("resuelto"):
				actividad.connect("resuelto", Callable(self, "_on_minijuego_resuelto"))
			else:
				push_error("La actividad no tiene señal resuelto")
				
		else:
			push_error("Escena de actividad no válida para el nivel " + str(nivel))
	else:
		print("No hay actividad definida para este nivel, puerta se abre directo")
		emit_signal("actividad_superada")

func _limpiar_minijuego() -> void:
	if ui_actividad:
		ui_actividad.queue_free()
		ui_actividad = null

func _on_minijuego_resuelto(exito: bool) -> void:
	_limpiar_minijuego()
		
	if exito:
		print("prueba superada, ABRIENDO PUERTA")
		emit_signal("actividad_superada")
	else:
		print("Prueba fallida, INTENTALO DE NUEVO")
		perder_vida()
		cambiar_estado(EstadoJuego.JUGANDO)
		
func establecer_parametros_actividad(parametros: Dictionary) -> void:
	if codigo_actividad_actual.is_empty():
		var codigo = generar_codigo()
		parametros["codigo"] = codigo
	else:
		parametros["codigo"] = codigo_actividad_actual
	parametros_actividad = parametros
	
func generar_codigo() -> Array[int]:
	if not codigo_generado or codigo_actividad_actual.is_empty():
		var num_random = RandomNumberGenerator.new()
		num_random.randomize()
		
		codigo_actividad_actual = []
		for i in range(4):
			codigo_actividad_actual.append(num_random.randi_range(1, 4))
		codigo_generado = true
		print("Codigo generado para el nivel: ", codigo_actividad_actual)
		
	return codigo_actividad_actual
