extends Control
class_name MenuPrincipal

const RUTA_INTRO     = "res://escenas/intro/Intro.tscn"
const RUTA_SELECCION = "res://escenas/menu/Seleccion_personaje/seleccion_personaje.tscn"
const RUTA_OPCIONES  = "res://escenas/menu/opciones_menu.tscn"
const RUTA_NUBE_SCN  = "res://escenas/menu/nubes.tscn"
const RUTA_MUSICA_MENU = "res://recursos/Audio/musica/neon-pulse-30s-307999.wav"

@onready var fondo: Control         = $Fondo
@onready var btn_jugar: Button      = $VBoxContainer/BtnJugar
@onready var btn_opciones: Button   = $VBoxContainer/BtnOpciones
@onready var btn_salir: Button      = $VBoxContainer/BtnSalir
@onready var lbl_version: Label     = $LblVersion

@onready var temporizador_nubes: Timer  = $temNubes
@onready var temporizador_espera: Timer = $temEspera

var escena_nube = preload(RUTA_NUBE_SCN)
var musica_menu = preload(RUTA_MUSICA_MENU)

var jugador_activo: bool = false
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

	# Conectar botones por código (más robusto que desde el editor)
	if btn_jugar:
		btn_jugar.pressed.connect(_on_jugar_pressed)
	if btn_opciones:
		btn_opciones.pressed.connect(_on_opciones_pressed)
	if btn_salir:
		btn_salir.pressed.connect(_on_salir_pressed)

	# Foco teclado
	if btn_jugar and btn_opciones and btn_salir:
		btn_jugar.grab_focus()
		btn_jugar.focus_neighbor_bottom = btn_opciones.get_path()
		btn_opciones.focus_neighbor_top = btn_jugar.get_path()
		btn_opciones.focus_neighbor_bottom = btn_salir.get_path()
		btn_salir.focus_neighbor_top = btn_opciones.get_path()

	# Timers
	if temporizador_espera:
		temporizador_espera.timeout.connect(_on_tem_espera_timeout)
		temporizador_espera.start()
	if temporizador_nubes:
		temporizador_nubes.timeout.connect(_on_tem_nubes_timeout)
		temporizador_nubes.start()

	# Nubes iniciales
	_crear_nube_normal()
	_crear_nube_fondo()

func _unhandled_input(event: InputEvent) -> void:
	# Cualquier interacción reinicia el temporizador de inactividad
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion or event is InputEventJoypadButton:
		jugador_activo = true
		if temporizador_espera:
			temporizador_espera.start()

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
# INACTIVIDAD → INTRO
# ---------------------------------------------------------
func _on_tem_espera_timeout() -> void:
	if not jugador_activo:
		print("[MenuPrincipal] Inactividad → Intro")
		get_tree().change_scene_to_file(RUTA_INTRO)
	else:
		jugador_activo = false
		if temporizador_espera:
			temporizador_espera.start()

# ---------------------------------------------------------
# BOTONES
# ---------------------------------------------------------
func _on_salir_pressed() -> void:
	print("[MenuPrincipal] BtnSalir PRESSED")
	if has_node("/root/Musica"):
		get_node("/root/Musica").call("detener")
	get_tree().quit()

func _on_opciones_pressed() -> void:
	print("[MenuPrincipal] BtnOpciones PRESSED")
	if ResourceLoader.exists(RUTA_OPCIONES):
		get_tree().change_scene_to_file(RUTA_OPCIONES)
	else:
		push_warning("Escena de opciones no implementada aún.")

func _on_jugar_pressed() -> void:
	print("[MenuPrincipal] BtnJugar PRESSED")

	if temporizador_espera:
		temporizador_espera.stop()

	GameManager.cambiar_estado(GameManager.EstadoJuego.SELECCION_PERSONAJE)
	get_tree().change_scene_to_file(RUTA_SELECCION)
