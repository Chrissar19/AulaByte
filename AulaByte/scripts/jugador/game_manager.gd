extends Node

# ====================================================================
# Señales globales
# ====================================================================
signal vida_actualizada(nueva_vida: int)
signal jugador_muerto
signal nivel_completado
signal personaje_seleccionado(id: int)
signal tiempo_actualizado(segundos: int)
signal tiempo_terminado
signal jugador_gana_puntos(puntos_totales: int)
signal estado_cambiado(nuevo_estado: String)
signal actividad_superada # FIX: faltaba declarar esta señal

# ====================================================================
# Estados (enum)
# ====================================================================
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

# Nombre legible para emitir en "estado_cambiado"
const NOMBRES_ESTADOS := [
	"MENU_PRINCIPAL",
	"SELECCION_PERSONAJE",
	"CARGANDO",
	"JUGANDO",
	"PAUSA",
	"MINIJUEGO",
	"TRANSICION_NIVEL",
	"GAME_OVER",
	"CREDITOS"
]

var estado_actual: int = EstadoJuego.MENU_PRINCIPAL
var estado_anterior: int

# ====================================================================
# Variables globales
# ====================================================================
# Personaje
var id_personaje: int = -1
var info_personaje: personajeInfo = null
var jugador_ref: Node = null

# Vidas
@export var VIDAS_INICIALES: int = 3
@export var VIDAS_MAX: int = 5
var vidas: int = VIDAS_INICIALES

# Puntos
var puntos: int = 0

# Tiempo
var tiempo_nivel_actual: float = 0.0
var tiempo_restante: float = 90.0
var tiempo_activo: bool = false

# =====================================================================
# Actividades por nivel (PackedScene)
# =====================================================================
var actividades_por_nivel := {
	0: preload("res://escenas/Niveles/actividades/actividad_cero.tscn"),
	1: preload("res://escenas/Niveles/actividades/actividad_primer_nivel.tscn"),
}

var parametros_actividad: Dictionary = {}
var codigo_actividad_actual: Array[int] = []
var codigo_generado: bool = false
var puerta_actual: Node = null
var ui_actividad: CanvasLayer = null

# Niveles
@export var niveles = preload("res://datos/niveles.tres")
var nivel_actual: int = 0
var nivel_precargado: PackedScene = null


func _ready() -> void:
	connect("actividad_superada", Callable(self, "_on_actividad_superada"))
# -----------------------------------------------------------------------
func _process(delta: float) -> void:
	#-- El tiempo contara solo si el juego esta corriendo
	if estado_actual == EstadoJuego.JUGANDO and tiempo_activo:
		tiempo_nivel_actual += delta
		if tiempo_restante > 0.0:
			tiempo_restante -= delta
			if tiempo_restante < 0.0:
				tiempo_restante = 0.0
			emit_signal("tiempo_actualizado", int(tiempo_restante))
			# Si se agotó el tiempo:
			if tiempo_restante <= 0.0:
				tiempo_activo = false
				emit_signal("tiempo_terminado")
				cambiar_estado(EstadoJuego.GAME_OVER)

# -----------------------------------------------------------------------
# Máquina de estados
# -----------------------------------------------------------------------
func cambiar_estado(nuevo_estado: int) -> void:
	_salir_estado(estado_actual)
	estado_anterior = estado_actual
	estado_actual = nuevo_estado
	_entrar_estado(estado_actual)
	# Emitir nombre legible del estado
	var nombre := "DESCONOCIDO"
	if estado_actual >= 0 and estado_actual < NOMBRES_ESTADOS.size():
		nombre = NOMBRES_ESTADOS[estado_actual]
	emit_signal("estado_cambiado", nombre)

func _entrar_estado(estado: int) -> void:
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

func _salir_estado(estado: int) -> void:
	match estado:
		EstadoJuego.MINIJUEGO:
			print("Saliendo de estado MINIJUEGO")
			if ui_actividad:
				ui_actividad.queue_free()
				ui_actividad = null

# -----------------------------------------------------------------------
# Conexión con el jugador
# -----------------------------------------------------------------------
func set_jugador(jugador: Node) -> void:
	jugador_ref = jugador
	if not jugador_ref:
		return

	#-- conecta a señales del jugador (usamos Callable para claridad)
	if jugador_ref.has_signal("jugador_gana_vida"):
		jugador_ref.connect("jugador_gana_vida", Callable(self, "_on_jugador_gana_vida"))
	if jugador_ref.has_signal("jugador_pierde_vida"):
		print("Conectando señal jugador_dmg de:", jugador_ref.name)
		jugador_ref.connect("jugador_pierde_vida", Callable(self, "_on_jugador_pierde_vida"))
	else:
		print("El jugador no tiene señal jugador_pierde_vida")

# -----------------------------------------------------------------------
# Callbacks del jugador
# -----------------------------------------------------------------------
func _on_jugador_gana_vida(vidas_actuales: int) -> void:
	vidas = vidas_actuales
	emit_signal("vida_actualizada", vidas) # FIX: señal consistente con la declarada

func _on_jugador_pierde_vida(dmg: int) -> void:
	print("GameManager: señal recibida, daño =", dmg)
	perder_vida()

# -----------------------------------------------------------------------
# Selección de personaje
# -----------------------------------------------------------------------
func seleccionar_personaje(id: int, info: personajeInfo) -> void:
	id_personaje = id
	info_personaje = info
	emit_signal("personaje_seleccionado", id)

func get_personaje() -> personajeInfo:
	return info_personaje

# -----------------------------------------------------------------------
# Puntos
# -----------------------------------------------------------------------
func agregar_puntos(cantidad: int) -> void:
	puntos += cantidad
	emit_signal("jugador_gana_puntos", puntos) # estoy enviando total; renombra señal si quieres enviar solo 'cantidad'

func reiniciar_puntos() -> void:
	puntos = 0
	emit_signal("jugador_gana_puntos", puntos)

func get_puntos() -> int:
	return puntos

# -----------------------------------------------------------------------
# Vidas
# -----------------------------------------------------------------------
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
	vidas = VIDAS_INICIALES
	emit_signal("vida_actualizada", vidas)

func get_vidas() -> int:
	return vidas

# -----------------------------------------------------------------------
# Tiempo
# -----------------------------------------------------------------------
func get_tiempo() -> float:
	return tiempo_nivel_actual

func iniciar_tiempo(segundos: float) -> void:
	tiempo_restante = segundos
	tiempo_activo = true
	cambiar_estado(EstadoJuego.JUGANDO)
	emit_signal("tiempo_actualizado", int(tiempo_restante))

# -----------------------------------------------------------------------
# Manejo de niveles
# -----------------------------------------------------------------------
func get_nivel_actual() -> PackedScene:
	if niveles and nivel_actual < niveles.nivel.size():
		return niveles.nivel[nivel_actual]
	return null

func precargar_nivel() -> void:
	var siguiente_indice = nivel_actual + 1
	if niveles and siguiente_indice < niveles.nivel.size():
		nivel_precargado = niveles.nivel[siguiente_indice]
		if nivel_precargado:
			ResourceLoader.load_threaded_request(nivel_precargado.resource_path)
			
func _on_actividad_superada() -> void:
	print("Señal actividad_superada recibida → pasando al siguiente nivel")
	siguiente_nivel()

func cargar_nivel_actual() -> void:
	tiempo_nivel_actual = 0.0
	iniciar_tiempo(90.0)
	var nivel: PackedScene = get_nivel_actual()
	if nivel:
		get_tree().change_scene_to_packed(nivel)
	else:
		print("AQUI VAN LOS CREDITOS")
		cambiar_estado(EstadoJuego.CREDITOS)

func transicion_siguiente_nivel() -> void:
	if not niveles or nivel_actual + 1 >= niveles.nivel.size():
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
	cambiar_estado(EstadoJuego.JUGANDO)
	codigo_generado = false
	codigo_actividad_actual.clear()

# =====================================================================
# ACTIVIDAD / MINIJUEGO
# =====================================================================
func solicitar_minijuego() -> void:
	print("Solicitando actividad para nivel: ", nivel_actual)
	# Cambiamos estado (pausa el juego)
	cambiar_estado(EstadoJuego.MINIJUEGO)

	var nivel := nivel_actual
	if actividades_por_nivel.has(nivel):
		var escena_actividad: PackedScene = actividades_por_nivel[nivel]
		if escena_actividad:
			# Crea un CanvasLayer para contener la UI
			ui_actividad = CanvasLayer.new()
			ui_actividad.layer = 15
			get_tree().root.add_child(ui_actividad)

			var actividad = escena_actividad.instantiate()

			# Pasar parámetros si la actividad acepta
			if not parametros_actividad.is_empty() and actividad.has_method("configurar_con_parametros"):
				actividad.configurar_con_parametros(parametros_actividad)

			# Si es UI -> full rect, si es Node2D -> posicionar en centro de cámara/viewport
			if actividad is Control:
				actividad.set_anchors_preset(Control.PRESET_FULL_RECT)
				actividad.mouse_filter = Control.MOUSE_FILTER_STOP
				actividad.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
				ui_actividad.add_child(actividad)
			elif actividad is Node2D:
				actividad.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
				ui_actividad.add_child(actividad)

				var pantalla = get_tree().root.get_viewport()
				var camara = pantalla.get_camera_2d()
				if camara:
					# FIX: usar la posición global de la cámara
					actividad.global_position = camara.global_position
				else:
					var tam_pantalla = pantalla.get_visible_rect()
					actividad.global_position = tam_pantalla.position + tam_pantalla.size / 2

			# Conectar señal resuelto
			if actividad.has_signal("resuelto"):
				actividad.connect("resuelto", Callable(self, "_on_minijuego_resuelto"))
			else:
				push_error("La actividad no tiene señal 'resuelto'")

		else:
			push_error("Escena de actividad no válida para el nivel " + str(nivel))
	else:
		print("No hay actividad definida para este nivel, puerta se abre directo")
		emit_signal("actividad_superada") # FIX: ahora la señal existe

func _on_minijuego_resuelto(exito: bool) -> void:
	# Elimina el CanvasLayer que contenía la actividad (si existe)
	if ui_actividad:
		ui_actividad.queue_free()
		ui_actividad = null

	if exito:
		print("prueba superada, ABRIENDO PUERTA")
		emit_signal("actividad_superada")
	else:
		print("Prueba fallida, INTENTALO DE NUEVO")
		perder_vida()
		# Volvemos a JUGAR (si aún hay vidas)
		if vidas > 0:
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
