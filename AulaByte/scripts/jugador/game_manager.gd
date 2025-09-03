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

# ============================================================================
# Variables globales
# ============================================================================
# Personaje
var id_personaje: int = -1
var info_personaje: personajeInfo = null
var jugador_ref: Node = null

# Vidas
var vidas: int = 3
const VIDAS_INICIALES: int = 3
const VIDAS_MAX: int = 5

# Puntos
var puntos: int = 0

# Tiempo
var tiempo_nivel_actual := 0.0
var tiempo_restante := 90.0
var tiempo_activo := false

# Estado del juego
enum EstadoJuego { MENU, JUGANDO, PAUSA, GAME_OVER }
var estado_actual: EstadoJuego = EstadoJuego.MENU


# =====================================================================
# DICCIONARIO DE ACTIVIDADES
# =====================================================================
var actividades_por_nivel := {
	#-- Empieza en 1 ya que el niveltuto no tiene minijuego 0 es para testear
	1: preload("res://escenas/Niveles/actividades/actividad_primer_nivel.tscn"),
}

var parametros_actividad: Dictionary = {}
var codigo_actividad_actual: Array[int] = []
var codigo_generado: bool = false
var puerta_actual: Node = null
var ui_actividad: CanvasLayer

#--------------------------------------------------------------------------------
# NIVELES
#--------------------------------------------------------------------------------
@export var niveles: Niveles = preload("res://datos/niveles.tres")
var nivel_actual: int = 0

#--------------------------------------------------------------------------------
# PROCESS
#--------------------------------------------------------------------------------
func _process(delta: float) -> void:
	#-- El tiempo contara solo si es juego esta corriendo
	if estado_actual == EstadoJuego.JUGANDO:
		tiempo_nivel_actual += delta
		if tiempo_restante > 0:
			tiempo_restante -= delta
			tiempo_restante = max(tiempo_restante, 0)
			emit_signal("tiempo_actualizado", int(tiempo_restante))
		
			if tiempo_restante == 0:
				tiempo_activo = false
				emit_signal("tiempo_terminado")

#--------------------------------------------------------------------------------
# CONEXION CON EL JUGADOR
#--------------------------------------------------------------------------------
func set_jugador(jugador: Node) -> void:
	jugador_ref = jugador
	
	#-- recibe la señal para cambios de vida
	if jugador_ref.has_signal("jugador_gana_vida"):
		jugador_ref.jugador_gana_vida.connect(_on_jugador_gana_vida)
		
	#-- recibe la señal cuando recibe daño
	if jugador_ref.has_signal("jugador_pierde_vida"):
		print("Conectando señal jugador_dmg de:", jugador_ref.name)
		jugador_ref.jugador_pierde_vida.connect(_on_jugador_pierde_vida)
	else:
		print("El jugador no tiene señal jugador_dmg")
		
#--------------------------------------------------------------------------------
# CALLBACKS DE SEÑALES DEL JUGADOR
#--------------------------------------------------------------------------------
func _on_jugador_gana_vida(vidas_actuales: int) -> void:
	vidas = vidas_actuales
	emit_signal("jugador_gana_vida", vidas)
	
func _on_jugador_pierde_vida(dmg: int) -> void:
	print("GameManager: señal recibida, daño =", dmg)
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
			
func _on_jugador_cayo_vacio() -> void:
	perder_vida()
	

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
	
func iniciar_tiempo(segundos: float) -> void:
	tiempo_restante = segundos
	tiempo_activo = true
	estado_actual = EstadoJuego.JUGANDO
	emit_signal("tiempo_actualizado", int(tiempo_restante))
	
# ============================================================================
# Manejo de niveles
# ============================================================================
func get_nivel_actual() -> PackedScene:
	if niveles and nivel_actual < niveles.nivel.size():
		return niveles.nivel[nivel_actual]
	return null
	
func cargar_nivel_actual() -> void:
	tiempo_nivel_actual = 0.0
	estado_actual = EstadoJuego.JUGANDO
	iniciar_tiempo(90.0)
	var nivel: PackedScene = get_nivel_actual()
	if nivel:
		get_tree().change_scene_to_packed(nivel)
	else:
		#-- AQUI VA LA ESCENA DE CREDITOS
		print("AQUI VAN LOS CREDITOS")
	
func siguiente_nivel() -> void:
	nivel_actual += 1
	cargar_nivel_actual()

func completar_nivel() -> void:
	emit_signal("nivel_completado")
	
func pantalla_de_carga() -> void:
	get_tree().change_scene_to_file("res://escenas/ui/pantalla_carga.tscn")

func reiniciar_nivel() -> void:
	reiniciar_puntos()
	reiniciar_vidas()
	
	tiempo_nivel_actual = 0.0
	estado_actual = EstadoJuego.JUGANDO
	
	codigo_generado = false
	codigo_actividad_actual.clear()
	
# ============================================================================
# Control del estado global
# ============================================================================
func cambiar_estado(nuevo_estado: EstadoJuego) -> void:
	estado_actual = nuevo_estado
	match estado_actual:
		EstadoJuego.JUGANDO:
			print("ESTADO JUGANDO")
		EstadoJuego.GAME_OVER:
			print("ESTADO GAME OVER")
			get_tree().change_scene_to_file("res://escenas/menu/menu_perder.tscn")


# =====================================================================
# ACTIVIDAD POR NIVEL
# =====================================================================
func solicitar_minijuego() -> void:
	print("Solicitando actividad para nivel: ", nivel_actual)
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
				
			#-- Pausa el nivel del juego
			await get_tree().process_frame
			get_tree().paused = true
				
		else:
			push_error("Escena de actividad no válida para el nivel " + str(nivel))
	else:
		print("No hay actividad definida para este nivel, puerta se abre directo")
		emit_signal("actividad_superada")
		

func _on_minijuego_resuelto(exito: bool) -> void:
	if ui_actividad:
		ui_actividad.queue_free()
		ui_actividad = null
		
		#-- Reanuda el juego
		get_tree().paused = false
		
		if exito:
			print("prueba superada, ABRIENDO PUERTA")
		emit_signal("actividad_superada")
	else:
		print("Prueba fallida, INTENTALO DE NUEVO")
		
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
