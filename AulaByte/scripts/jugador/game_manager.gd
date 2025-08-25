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
	0: preload("res://escenas/Niveles/actividades/actividad_primer_nivel.tscn"),
}

var puerta_actual: Node = null
@export var modo_tester_actividad := false

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
func solicitar_minijuego(puerta: Node) -> void:
	puerta_actual = puerta
	var nivel := nivel_actual
	print("Nivel actual: ", nivel_actual)
	if modo_tester_actividad:
		nivel = 0
		
	var escena_actividad: PackedScene = actividades_por_nivel.get(nivel, null)
	if not escena_actividad:
		print("No hay actividad para este nivel, ABRIENDO PUERTA")
		puerta.abrir_puerta()
		return
		
	var actividad = escena_actividad.instantiate()
	actividad.pause_mode = Node.PROCESS_MODE_PAUSABLE
	get_tree().paused = true
	get_tree().current_scene.add_child(actividad)
	
	#-- Conectar las señales
	actividad.resuelto.connect(func(exito: bool):
		get_tree().paused = false
		if exito:
			print("Minijuego resuelto, ABRIENDO PUERTA")
			puerta_actual.abrir_puerta()
		puerta_actual = null
		actividad.queue_free()
	)
