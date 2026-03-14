extends Control
class_name MenuPrincipal

const RUTA_INTRO = "res://escenas/intro/Intro.tscn"
const RUTA_SELECCION = "res://escenas/menu/Seleccion_personaje/seleccion_personaje.tscn"
const RUTA_OPCIONES = "res://escenas/menu/opciones_menu.tscn"
const RUTA_CREDITOS = "res://escenas/menu/creditos.tscn"
const RUTA_NUBE_SCN = "res://escenas/menu/nubes.tscn"
const RUTA_MUSICA_MENU = "res://recursos/Audio/musica/MenuPrincipal.wav"

@onready var fondo: Control = $Fondo
@onready var btn_jugar: Button = $VBoxContainer/BtnJugar
@onready var btn_opciones: Button = $VBoxContainer/BtnOpciones
@onready var btn_creditos: Button = $VBoxContainer/BtnCreditos
@onready var btn_salir: Button = $VBoxContainer/BtnSalir
@onready var lbl_version: Label = $LblVersion

@onready var temporizador_nubes: Timer  = $temNubes
@onready var temporizador_espera: Timer = $temEspera

var escena_nube = preload(RUTA_NUBE_SCN)
var musica_menu = preload(RUTA_MUSICA_MENU)

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	print("[MenuPrincipal] _ready()")

	rng.randomize()

	# Música del menú (si tienes autoload "Musica")
	if has_node("/root/Musica"):
		get_node("/root/Musica").call("reproducir", musica_menu, true)

	# Versión del proyecto (opcional)
	if lbl_version:
		var ver = ProjectSettings.get_setting("application/config/version", "v0.1")
		lbl_version.text = str(ver)

	# Conectar botones
	if btn_jugar:
		btn_jugar.pressed.connect(_on_jugar_pressed)
	if btn_opciones:
		btn_opciones.pressed.connect(_on_opciones_pressed)
	if btn_creditos:
		btn_creditos.pressed.connect(_on_creditos_pressed)
	if btn_salir:
		btn_salir.pressed.connect(_on_salir_pressed)

	# Foco teclado
	if btn_jugar and btn_opciones and btn_creditos and btn_salir:
		btn_jugar.grab_focus()
		btn_jugar.focus_neighbor_bottom = btn_opciones.get_path()
		btn_opciones.focus_neighbor_top = btn_jugar.get_path()
		btn_opciones.focus_neighbor_bottom = btn_creditos.get_path()
		btn_creditos.focus_neighbor_top = btn_opciones.get_path()
		btn_creditos.focus_neighbor_bottom = btn_salir.get_path()
		btn_salir.focus_neighbor_top = btn_creditos.get_path()

	# Timers
	if temporizador_espera:
		temporizador_espera.timeout.connect(_on_tem_espera_timeout)
		# IMPORTANTE: solo se inicia una vez; que tenga wait_time = 45 en el editor
		temporizador_espera.start()
	if temporizador_nubes:
		temporizador_nubes.timeout.connect(_on_tem_nubes_timeout)
		temporizador_nubes.start()

	# Nubes iniciales
	_crear_nube_normal()
	_crear_nube_fondo()

# ---------------------------------------------------------
# NUBES
# ---------------------------------------------------------
func _crear_nube(z: int, alto_min: int, alto_max: int, tam_min: float, tam_max: float, vel_min: float, vel_max: float) -> void:
	if escena_nube == null:
		return

	var nube = escena_nube.instantiate()
	if nube == null:
		return

	var altura := rng.randi_range(alto_min, alto_max)
	nube.position = Vector2(-50.0, float(altura))

	# Asumimos que la escena de la nube tiene una variable 'velocidad'
	if "velocidad" in nube:
		nube.velocidad = rng.randf_range(vel_min, vel_max)

	if nube is CanvasItem:
		nube.z_index = z

	var s := rng.randf_range(tam_min, tam_max)
	nube.scale = Vector2(s, s)

	if fondo:
		fondo.add_child(nube)
	else:
		add_child(nube)

func _crear_nube_normal() -> void:
	var posibles_z = [-1, 0, 1]
	var idx := rng.randi_range(0, posibles_z.size() - 1)
	var z_nube: int = posibles_z[idx]
	_crear_nube(z_nube, 5, 120, 0.5, 1.5, 0.8, 40.0)

func _crear_nube_fondo() -> void:
	_crear_nube(-1, 4, 280, 0.2, 0.7, 0.15, 10.0)

func _on_tem_nubes_timeout() -> void:
	if rng.randf() < 0.6:
		_crear_nube_normal()
	else:
		_crear_nube_fondo()

# ---------------------------------------------------------
# ESPERA FIJA → INTRO
# ---------------------------------------------------------
func _on_tem_espera_timeout() -> void:
	print("[MenuPrincipal] Tiempo límite alcanzado → Intro")
	# Si aún seguimos en el menú (no se ha pulsado nada importante), pasamos a la intro
	get_tree().change_scene_to_file(RUTA_INTRO)

# ---------------------------------------------------------
# BOTONES
# ---------------------------------------------------------
func _detener_temporizador_intro() -> void:
	if temporizador_espera and temporizador_espera.is_stopped() == false:
		temporizador_espera.stop()

func _on_salir_pressed() -> void:
	print("[MenuPrincipal] BtnSalir PRESSED")
	_detener_temporizador_intro()
	if has_node("/root/Musica"):
		get_node("/root/Musica").call("detener")
	get_tree().quit()

func _on_opciones_pressed() -> void:
	print("[MenuPrincipal] BtnOpciones PRESSED")
	_detener_temporizador_intro()
	if ResourceLoader.exists(RUTA_OPCIONES):
		get_tree().change_scene_to_file(RUTA_OPCIONES)
	else:
		push_warning("Escena de opciones no implementada aún.")

func _on_creditos_pressed() -> void:
	print("[MenuPrincipal] BtnCreditos PRESSED")
	_detener_temporizador_intro()
	get_tree().change_scene_to_file(RUTA_CREDITOS)

func _on_jugar_pressed() -> void:
	print("[MenuPrincipal] BtnJugar PRESSED")
	_detener_temporizador_intro()
	GameManager.cambiar_estado(GameManager.EstadoJuego.SELECCION_PERSONAJE)
	get_tree().change_scene_to_file(RUTA_SELECCION)
	
