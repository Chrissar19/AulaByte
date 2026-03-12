#-- Game Manager
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

#---------------------------------------------------------------------
# Guardar
#================================================================
const SAVE_PATH := "user://progreso_aulabyte.cfg"
var nivel_max_desbloqueado: int = 0

# ====================================================================
# Estados (enum)
# ====================================================================
enum EstadoJuego {
	MENU_PRINCIPAL,
	SELECCION_PERSONAJE,
	SELECCION_NIVEL,
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
	"SELECCION_NIVEL",
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
var volver_a_nivel_desde_opciones: bool = false 

const RUTA_MENU_PAUSA := "res://escenas/ui/menu_pausa.tscn"
var escena_menu_pausa: PackedScene = preload(RUTA_MENU_PAUSA)

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

# Checkpoint por nivel
var puntos_base_nivel: int = 0
var nivel_en_progreso: int = -1

# Causa de muerte
var causa_muerte: String = ""

# Tiempo
var tiempo_nivel_actual: float = 0.0
var tiempo_restante: float = 90.0
var tiempo_activo: bool = false
var _ultimo_segundos: int = -1
var delay_puerta: float = 1.5

# =====================================================================
# Actividades por nivel (PackedScene)
# =====================================================================
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
	process_mode = Node.PROCESS_MODE_ALWAYS
	connect("actividad_superada", Callable(self, "_on_actividad_superada"))
	
	if typeof(AudioManager) != TYPE_NIL:
		if not is_connected("estado_cambiado", Callable(AudioManager, "_on_estado_cambiado")):
			connect("estado_cambiado", Callable(AudioManager, "_on_estado_cambiado"))
		else:
			push_warning("AudioManager no está configurado como Autoload o el nombre no coincide.")
	
	cargar_progreso()
	cambiar_estado(estado_actual)
	
# -----------------------------------------------------------------------
func _process(delta: float) -> void:
	# El tiempo cuenta solo si el juego está corriendo
	if estado_actual == EstadoJuego.JUGANDO and tiempo_activo:
		tiempo_nivel_actual += delta
		if tiempo_restante > 0.0:
			tiempo_restante = max(tiempo_restante - delta, 0.0)
		
		var seg := int(tiempo_restante)
		if seg != _ultimo_segundos:
			_ultimo_segundos = seg
			emit_signal("tiempo_actualizado", seg)
			
		# Si se agotó el tiempo:
		if tiempo_restante <= 0.0 and tiempo_activo:
			tiempo_activo = false
			causa_muerte = "Se agoto el tiempo"
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
	
	var nombre := "DESCONOCIDO"
	if estado_actual >= 0 and estado_actual < NOMBRES_ESTADOS.size():
		nombre = NOMBRES_ESTADOS[estado_actual]
	emit_signal("estado_cambiado", nombre)

func _entrar_estado(estado: int) -> void:
	match estado:
		EstadoJuego.MENU_PRINCIPAL:
			print("Entrando a estado MENU_PRINCIPAL")
			get_tree().paused = false
			tiempo_activo = false
			tiempo_nivel_actual = 0.0
			_ultimo_segundos = -1
			
		EstadoJuego.SELECCION_PERSONAJE:
			print("Entrando a estado SELECCION_PERSONAJE")
			get_tree().paused = false
			tiempo_activo = false
			
		EstadoJuego.SELECCION_NIVEL:
			print("Entrando a estado SELECCION_NIVEL")
			tiempo_activo = false
			get_tree().change_scene_to_file("res://escenas/menu/menu_niveles.tscn")
			
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
			get_tree().paused = false
			precargar_nivel()
			pantalla_de_carga()
			
		EstadoJuego.TRANSICION_NIVEL:
			print("Entrando a estado TRANSICION_NIVEL")
			get_tree().paused = false
			transicion_siguiente_nivel()
			
		EstadoJuego.GAME_OVER:
			print("Entrando a estado GAME_OVER")
			get_tree().change_scene_to_file("res://escenas/menu/menu_perder.tscn")
			
		EstadoJuego.CREDITOS:
			print("Entrando a estado CREDITOS")
			get_tree().change_scene_to_file("res://escenas/menu/creditos.tscn")

func _salir_estado(estado: int) -> void:
	match estado:
		EstadoJuego.MINIJUEGO:
			print("Saliendo de estado MINIJUEGO")
			if ui_actividad:
				ui_actividad.queue_free()
				ui_actividad = null
			get_tree().paused = false

func get_causa_muerte() -> String:
	return causa_muerte

# -----------------------------------------------------------------------
# Checkpoint por nivel
# -----------------------------------------------------------------------
func registrar_checkpoint_nivel() -> void:
	if nivel_en_progreso != nivel_actual:
		puntos_base_nivel = puntos
		nivel_en_progreso = nivel_actual
		print("[GM] Checkpoint nivel ", nivel_actual, " = ", puntos_base_nivel)
		
# -----------------------------------------------------------------------
# PAUSA
# -----------------------------------------------------------------------
func pausar_juego() -> void:
	if estado_actual != EstadoJuego.JUGANDO:
		return
	
	cambiar_estado(EstadoJuego.PAUSA)
	
	if escena_menu_pausa:
		var menu_pausa = escena_menu_pausa.instantiate()
		
		# Para que siga funcionando mientras el árbol está en pausa
		if menu_pausa is CanvasItem:
			menu_pausa.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		
		get_tree().root.add_child(menu_pausa)
	else:
		push_warning("No se asignó 'escena_menu_pausa' en GameManager.")


func reanudar_juego() -> void:
	if estado_actual != EstadoJuego.PAUSA:
		return
	
	# Volver al estado de juego normal
	cambiar_estado(EstadoJuego.JUGANDO)


# -----------------------------------------------------------------------
# Conexión con el jugador
# -----------------------------------------------------------------------
func set_jugador(jugador: Node) -> void:
	jugador_ref = jugador
	if not jugador_ref:
		return

	if jugador_ref.has_signal("jugador_gana_vida"):
		jugador_ref.connect("jugador_gana_vida", Callable(self, "_on_jugador_gana_vida"))
	if jugador_ref.has_signal("jugador_pierde_vida"):
		print("Conectando señal jugador_dmg de:", jugador_ref.name)
		jugador_ref.connect("jugador_pierde_vida", Callable(self, "_on_jugador_pierde_vida"))
	if jugador_ref.has_signal("jugador_gana_puntos"):
		jugador_ref.connect("jugador_gana_puntos", Callable(self, "_on_jugador_gana_puntos"))
	else:
		print("El jugador no tiene señal jugador_pierde_vida")

# -----------------------------------------------------------------------
# Callbacks del jugador
# -----------------------------------------------------------------------
func _on_jugador_gana_vida(vidas_actuales: int) -> void:
	vidas = vidas_actuales
	emit_signal("vida_actualizada", vidas)

func _on_jugador_pierde_vida(dmg: int) -> void:
	print("GameManager: señal recibida, daño =", dmg)
	perder_vida()

func _on_jugador_gana_puntos(cantidad: int) -> void:
	agregar_puntos(cantidad)

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
	print("[GM] agregar_puntos: +", cantidad, " → ", puntos)
	emit_signal("jugador_gana_puntos", puntos)

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
			causa_muerte = "Te has quedado sin vidas"
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
# HABILIDADES / POWER-UPS
# -----------------------------------------------------------------------
func aplicar_powerup_velocidad(duracion: float, factor: float) -> void:
	if jugador_ref == null:
		print("No se pudo aplicar power-up de velocidad: jugador no asignado.")
		return
	if jugador_ref.has_method("activar_habilidad_velocidad"):
		jugador_ref.activar_habilidad_velocidad(duracion, factor)
	else:
		print("El jugador no tiene el método activar_habilidad_velocidad().")

func aplicar_powerup_salto(duracion: float, factor: float) -> void:
	if jugador_ref == null:
		print("No se pudo aplicar power-up de salto: jugador no asignado.")
		return
	if jugador_ref.has_method("activar_habilidad_salto"):
		jugador_ref.activar_habilidad_salto(duracion, factor)
	else:
		print("El jugador no tiene el método activar_habilidad_salto().")

# -----------------------------------------------------------------------
# Tiempo
# -----------------------------------------------------------------------
func get_tiempo() -> float:
	return tiempo_nivel_actual

func iniciar_tiempo(segundos: float) -> void:
	tiempo_restante = max(segundos, 0.0)
	tiempo_activo = true
	_ultimo_segundos = int(tiempo_restante)
	emit_signal("tiempo_actualizado", _ultimo_segundos)
	cambiar_estado(EstadoJuego.JUGANDO)

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
	print("[GM] cargar_nivel_actual → nivel ", nivel_actual, " puntos = ", puntos)
	
	# Registrar checkpoint solo la primera vez que entramos a este nivel
	registrar_checkpoint_nivel()
	
	# Resetear SOLO cosas de nivel (no puntos, no vidas)
	preparar_nivel()
	
	var nivel: PackedScene = get_nivel_actual()
	if nivel:
		get_tree().change_scene_to_packed(nivel)
	else:
		cambiar_estado(EstadoJuego.CREDITOS)

func transicion_siguiente_nivel() -> void:
	if not niveles or nivel_actual + 1 >= niveles.nivel.size():
		cambiar_estado(EstadoJuego.CREDITOS)
	else:
		nivel_actual += 1
		if nivel_actual > nivel_max_desbloqueado:
			nivel_max_desbloqueado = nivel_actual
			guardar_progreso()
		cambiar_estado(EstadoJuego.CARGANDO)

func siguiente_nivel() -> void:
	cambiar_estado(EstadoJuego.TRANSICION_NIVEL)

func completar_nivel() -> void:
	emit_signal("nivel_completado")

func pantalla_de_carga() -> void:
	get_tree().change_scene_to_file("res://escenas/ui/pantalla_carga.tscn")
	
func reintentar_nivel_actual() -> void:
	# Solo reiniciamos vidas y restauramos puntos al checkpoint del nivel
	reiniciar_vidas()
	puntos = puntos_base_nivel
	emit_signal("jugador_gana_puntos", puntos)
	print("[GM] Reintentar nivel ", nivel_actual, " → puntos restaurados a ", puntos_base_nivel)
	
	# Volver a cargar el mismo nivel
	cargar_nivel_actual()

func reiniciar_nivel() -> void:
	reiniciar_puntos()
	reiniciar_vidas()
	preparar_nivel()
	cambiar_estado(EstadoJuego.JUGANDO)
	
func preparar_nivel() -> void:
	print("[GM] Preparando nuevo nivel: Limpiando parámetros.")
	tiempo_nivel_actual = 0.0
	parametros_actividad.clear()
	codigo_actividad_actual.clear()
	codigo_generado = false
	causa_muerte = ""

func ir_a_menu_principal() -> void:
	nivel_en_progreso = -1
	puntos_base_nivel = 0
	cambiar_estado(EstadoJuego.MENU_PRINCIPAL)
	get_tree().change_scene_to_file("res://escenas/menu/menu_principal.tscn")
	
func guardar_progreso() -> void:
	var config = ConfigFile.new()
	config.set_value("Progreso", "nivel_max", nivel_max_desbloqueado)
	config.save(SAVE_PATH)
	print("[GM] progreso guardado: Nivel ", nivel_max_desbloqueado)
	
func cargar_progreso() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		nivel_max_desbloqueado = config.get_value("Progreso", "nivel_max", 0)
		print("[GM] Progreso cargado. Nivel maximo: ", nivel_max_desbloqueado)

# =====================================================================
# ACTIVIDAD / MINIJUEGO
# =====================================================================
func solicitar_minijuego() -> void:
	cambiar_estado(EstadoJuego.MINIJUEGO)
	
	var escena := get_tree().current_scene
	var actividad_escena: PackedScene = null

	if escena:
		if escena.has_method("get_actividad"):
			actividad_escena = escena.get_actividad()
		elif "actividad" in escena:
			actividad_escena = escena.actividad
			
	if not actividad_escena:
		print("No hay actividad definida para este nivel, puerta se abre directo")
		emit_signal("actividad_superada")
		return
		
	ui_actividad = CanvasLayer.new()
	ui_actividad.layer = 15
	get_tree().root.add_child(ui_actividad)
	
	var actividad = actividad_escena.instantiate()

	if not parametros_actividad.is_empty() and actividad.has_method("configurar_con_parametros"):
		actividad.configurar_con_parametros(parametros_actividad)

	if actividad is Control:
		actividad.set_anchors_preset(Control.PRESET_FULL_RECT)
		actividad.mouse_filter = Control.MOUSE_FILTER_STOP
	actividad.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	ui_actividad.add_child(actividad)

	if actividad.has_signal("resuelto"):
		actividad.connect("resuelto", Callable(self, "_on_minijuego_resuelto"))
	else:
		push_error("La actividad no tiene señal 'resuelto'")

	if actividad.has_signal("cancelado"):
		actividad.connect("cancelado", Callable(self, "_on_minijuego_cancelado"))
	elif actividad.has_signal("cancelar"):
		actividad.connect("cancelar", Callable(self, "_on_minijuego_cancelado"))

func _on_minijuego_resuelto(exito: bool) -> void:
	if ui_actividad:
		ui_actividad.queue_free()
		ui_actividad = null

	if exito:
		print("prueba superada")

		if puerta_actual and is_instance_valid(puerta_actual):
			var estaba_pausado := get_tree().paused
			get_tree().paused = false

			await puerta_actual.abrir_puerta()

			if delay_puerta > 0.0:
				await get_tree().create_timer(delay_puerta).timeout
			get_tree().paused = estaba_pausado

		siguiente_nivel()
	else:
		print("Prueba fallida, INTENTALO DE NUEVO")
		perder_vida()
		if vidas > 0:
			cambiar_estado(EstadoJuego.JUGANDO)

func _on_minijuego_cancelado() -> void:
	print("Minijuego cancelado por el jugador (sin perder vida)")
	
	if ui_actividad:
		ui_actividad.queue_free()
		ui_actividad = null
	
	get_tree().paused = false
	
	if estado_actual == EstadoJuego.MINIJUEGO:
		cambiar_estado(EstadoJuego.JUGANDO)

# En GameManager.gd

func establecer_parametros_actividad(nuevos_parametros: Dictionary) -> void:
	# 1. Si recibimos un diccionario vacío, no hacemos nada para no borrar datos previos
	if nuevos_parametros.is_empty():
		return

	# 2. Si los nuevos parámetros traen un "codigo", actualizamos la variable interna
	if nuevos_parametros.has("codigo"):
		var nuevo_cod = nuevos_parametros["codigo"]
		if nuevo_cod is Array:
			codigo_actividad_actual = nuevo_cod.duplicate()
			codigo_generado = true # Marcamos como generado para que no cree uno aleatorio
	
	# 3. FUSIÓN: Agregamos o actualizamos las claves una por una
	# Esto permite que el Nivel mande el código y la Puerta mande los intentos
	for clave in nuevos_parametros.keys():
		parametros_actividad[clave] = nuevos_parametros[clave]
	
	print("[GM] Parámetros Universales actualizados: ", parametros_actividad)

func generar_codigo(longitud: int = 4) -> Array[int]:
	# Solo generamos si no hay un código ya establecido por el nivel
	if not codigo_generado or codigo_actividad_actual.is_empty():
		var num_random = RandomNumberGenerator.new()
		num_random.randomize()

		codigo_actividad_actual = []
		for i in range(longitud):
			codigo_actividad_actual.append(num_random.randi_range(1, 4))

		codigo_generado = true
		# También lo guardamos en el diccionario de parámetros para la actividad
		parametros_actividad["codigo"] = codigo_actividad_actual
		print("[GM] Código aleatorio generado: ", codigo_actividad_actual)
	
	return codigo_actividad_actual

func terminar_juego() -> void:
	print("AQUI VAN LOS CREDITOS")
	cambiar_estado(EstadoJuego.CREDITOS)
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if estado_actual == EstadoJuego.JUGANDO:
			# ESC → Pausar y abrir menú
			pausar_juego()
			return
		elif estado_actual == EstadoJuego.PAUSA:
			# ESC → Cerrar menú de pausa (si existe) y reanudar
			for child in get_tree().root.get_children():
				if child is MenuPausa:
					child.queue_free()
			reanudar_juego()
			return
	
	if estado_actual != EstadoJuego.JUGANDO:
		return
		
	if event.is_action_pressed("reiniciar_nivel"):
		print("[GM] Reinicio manual de nivel por tecla (R)")
		reintentar_nivel_actual()
